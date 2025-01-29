import Foundation
import os.log

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    private init() {}
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LearningMentor", category: "Performance")
    private var metrics: [String: TimeInterval] = [:]
    
    // 开始测量
    func startMeasuring(_ identifier: String) {
        metrics[identifier] = Date().timeIntervalSinceReferenceDate
    }
    
    // 结束测量并记录
    func stopMeasuring(_ identifier: String, threshold: TimeInterval = 0.1) {
        guard let startTime = metrics[identifier] else { return }
        
        let endTime = Date().timeIntervalSinceReferenceDate
        let duration = endTime - startTime
        
        // 如果执行时间超过阈值，记录警告
        if duration > threshold {
            logger.warning("⚠️ Performance warning: \(identifier) took \(String(format: "%.3f", duration))s")
        } else {
            logger.debug("✓ \(identifier) completed in \(String(format: "%.3f", duration))s")
        }
        
        metrics.removeValue(forKey: identifier)
    }
    
    // 监控内存使用
    func reportMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            logger.debug("📊 Memory usage: \(String(format: "%.1f", usedMB))MB")
        }
    }
    
    // 监控 CPU 使用率
    func reportCPUUsage() {
        var thread_list: thread_act_array_t?
        var thread_count: mach_msg_type_number_t = 0
        
        let kerr = task_threads(mach_task_self_, &thread_list, &thread_count)
        
        if kerr == KERN_SUCCESS, let threadList = thread_list {
            var totalCPU: Double = 0
            
            for i in 0..<Int(thread_count) {
                var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = thread_basic_info()
                
                let err = withUnsafeMutablePointer(to: &thinfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadList[i],
                                  thread_flavor_t(THREAD_BASIC_INFO),
                                  $0,
                                  &thread_info_count)
                    }
                }
                
                if err == KERN_SUCCESS {
                    let cpuUsage = Double(thinfo.cpu_usage) / Double(TH_USAGE_SCALE)
                    totalCPU += cpuUsage
                }
            }
            
            logger.debug("🔄 CPU usage: \(String(format: "%.1f", totalCPU * 100))%")
            vm_deallocate(mach_task_self_,
                         vm_address_t(UInt(bitPattern: thread_list)),
                         vm_size_t(Int(thread_count) * MemoryLayout<thread_t>.stride))
        }
    }
    
    // 监控磁盘使用
    func reportDiskUsage() {
        let appSize = calculateDiskUsage()
        let sizeMB = Double(appSize) / 1024.0 / 1024.0
        logger.debug("💾 App storage usage: \(String(format: "%.1f", sizeMB))MB")
    }
    
    private func calculateDiskUsage() -> Int64 {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        func directorySize(url: URL) -> Int64 {
            guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .isDirectoryKey]) else { return 0 }
            
            var size: Int64 = 0
            for case let fileURL as URL in enumerator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .isDirectoryKey]),
                      let fileSize = resourceValues.totalFileAllocatedSize else { continue }
                size += Int64(fileSize)
            }
            return size
        }
        
        return directorySize(url: documentsPath)
    }
} 