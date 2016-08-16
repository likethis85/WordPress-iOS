import Foundation
import WordPressShared

@objc public class ReaderCardGalleryStripView: UIView
{
    // MARK: - Lifecycle Methods

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Accessors

    public override func intrinsicContentSize() -> CGSize {
        return sizeThatFits(frame.size)
    }

    public override func sizeThatFits(size: CGSize) -> CGSize {
        return size
    }


    // MARK: - Configuration

    public func configureView(contentProvider: ReaderPostContentProvider?) {
        invalidateIntrinsicContentSize()
    }

}
