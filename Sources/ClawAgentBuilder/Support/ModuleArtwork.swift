import AppKit
import Foundation

enum ModuleArtwork {
    case appIcon
    case gettingToKnowYou
    case lobsterOffice1
    case lobsterOffice2
    case lobsterOffice3
    case lobsterOffice4
    case lobsterOffice5
    case lobsterOffice6

    private var resourceName: String {
        switch self {
        case .appIcon:
            return "app-icon"
        case .gettingToKnowYou:
            return "getting-to-know-you"
        case .lobsterOffice1:
            return "lobster-office-1"
        case .lobsterOffice2:
            return "lobster-office-2"
        case .lobsterOffice3:
            return "lobster-office-3"
        case .lobsterOffice4:
            return "lobster-office-4"
        case .lobsterOffice5:
            return "lobster-office-5"
        case .lobsterOffice6:
            return "lobster-office-6"
        }
    }

    private var fileExtension: String {
        switch self {
        case .appIcon:
            return "png"
        case .gettingToKnowYou,
             .lobsterOffice1,
             .lobsterOffice2,
             .lobsterOffice3,
             .lobsterOffice4,
             .lobsterOffice5,
             .lobsterOffice6:
            return "jpg"
        }
    }

    var url: URL? {
        Bundle.module.url(forResource: resourceName, withExtension: fileExtension)
    }

    var image: NSImage? {
        guard let url else {
            return nil
        }

        return NSImage(contentsOf: url)
    }

    static let officeGallery: [ModuleArtwork] = [
        .lobsterOffice1,
        .lobsterOffice2,
        .lobsterOffice3,
        .lobsterOffice4,
        .lobsterOffice5,
        .lobsterOffice6,
    ]
}
