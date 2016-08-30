import Foundation
import WordPressShared

@objc public class ReaderCardGalleryStripView: UIView
{
    @IBOutlet private weak var galleryImageView1: UIImageView!
    @IBOutlet private weak var galleryImageView2: UIImageView!
    @IBOutlet private weak var numberOfImagesLabel: UILabel!
    @IBOutlet private weak var viewGalleryLabel: UIButton!

    // MARK: - Lifecycle Methods

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Configuration

    public func configureView(contentProvider: ReaderPostContentProvider?) {

        guard let cp = contentProvider else {
            reset()
            return
        }

        configureGalleryImageStrip(cp)
        invalidateIntrinsicContentSize()
    }

    private func reset() {
        galleryImageView1.image = nil
        galleryImageView2.image = nil
    }

    private func configureGalleryImageStrip(contentProvider: ReaderPostContentProvider) {
        //TODO: Stuff goes here

    }

}
