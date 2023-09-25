import Combine
import MachO
import SwiftUI

class MemoryInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "Memory Information"
    }

    func memoryFootprint() -> Float? {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return nil }

        let usedBytes = Float(info.phys_footprint)
        return usedBytes
    }

    func formattedMemoryFootprint() -> String {
        let usedBytes: UInt64? = UInt64(memoryFootprint() ?? 0)
        let usedMB = Double(usedBytes ?? 0) / 1024 / 1024
        let usedMBAsString = String(format: "%0.02f MiB", usedMB)
        return usedMBAsString
    }

    /// https://github.com/PerfectlySoft/Perfect-SysInfo/blob/master/Sources/PerfectSysInfo/PerfectSysInfo.swift#L359
    func vm_stat() -> [String: Int] {
        let size = MemoryLayout<vm_statistics>.size / MemoryLayout<integer_t>.size
        let pStat = UnsafeMutablePointer<integer_t>.allocate(capacity: size)
        var stat: [String: Int] = [:]
        var count = mach_msg_type_number_t(size)
        if host_statistics(mach_host_self(), HOST_VM_INFO, pStat, &count) == 0 {
            let array = Array(UnsafeBufferPointer(start: pStat, count: size))
            let cnt = min(tags.count, array.count)
            for i in 0 ... cnt - 1 {
                let key = tags[i]
                let value = array[i]
                stat[key] = Int(value) / 256
            } // next i
        } // end if
        pStat.deallocate()
        return stat
    }

    func ggsdf() -> (kern_return_t, vm_size_t) {
        var pageSize: vm_size_t = 0
        let result = withUnsafeMutablePointer(to: &pageSize) { size -> kern_return_t in
            host_page_size(mach_host_self(), size)
        }

        return (result, pageSize)
    }

    let tags = ["free", "active", "inactive", "wired", "zero_filled", "reactivations", "pageins", "pageouts", "faults", "cow", "lookups", "hits"]

    @MainActor override func reload() async {
        enabled = true
        rows.removeAll()

        rows.append(.row(title: "Memory Footprint", content: formattedMemoryFootprint()))

        let (kern_result, page_size) = ggsdf()
        if kern_result == KERN_SUCCESS {
            rows.append(.row(title: "Page Size", content: "\(page_size) bytes"))
        }
        let stats = vm_stat()

        for key in tags {
            if let val = stats[key] {
                rows.append(.row(title: key, content: String(format: "%d MB", val)))
            }
        }
    }
}
