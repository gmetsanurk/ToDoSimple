import UIKit

struct Colors {
    static let backgroundColor = UIColor.systemBackground
}

struct AppGeometry {
    struct HomeScreen {
        static let titleLabelHeight: CGFloat = 50
        static let searchBarHeight: CGFloat = 44
        static let bottomToolbarHeight: CGFloat = 50
        static let horizontalMargin: CGFloat = 16
    }
    
    struct HomeCell {
        static let checkBoxTopMargin: CGFloat = 10
        static let checkBoxLeadingMargin: CGFloat = 16
        static let checkBoxSize: CGFloat = 32
        static let taskLabelTopMargin: CGFloat = 14
        static let taskLabelLeadingMargin: CGFloat = 16
        static let taskLabelTrailingMargin: CGFloat = 16
        static let cellMinimumHeight: CGFloat = 90
    }
    
    struct EditTaskScreen {
        static let backButtonLeftMargin: CGFloat = 16
        static let backButtonTopMargin: CGFloat = 8
        static let backButtonWidth: CGFloat = 100
        static let backButtonHeight: CGFloat = 44
        static let textViewTopMargin: CGFloat = 20
        static let textViewHorizontalMargin: CGFloat = 16
        static let textViewBottomMargin: CGFloat = 16
    }
}
