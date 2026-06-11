import Foundation

enum AppSupportPaths {
    static var applicationSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        return base.appendingPathComponent("VeilPDF", isDirectory: true)
    }

    static var runtimeDirectory: URL {
        applicationSupportDirectory.appendingPathComponent("Runtime", isDirectory: true)
    }

    static var runtimeVirtualEnvironment: URL {
        runtimeDirectory.appendingPathComponent("venv", isDirectory: true)
    }

    static var runtimePython: URL {
        runtimeVirtualEnvironment.appendingPathComponent("bin/python")
    }

    static var modelCacheDirectory: URL {
        applicationSupportDirectory.appendingPathComponent("ModelCache", isDirectory: true)
    }
}
