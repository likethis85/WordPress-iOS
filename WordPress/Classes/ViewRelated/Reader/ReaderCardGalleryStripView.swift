import Foundation
import WordPressShared

@objc public class ReaderCardGalleryStripView: UIView
{
    @IBOutlet private weak var galleryImageView1: UIImageView!
    @IBOutlet private weak var galleryImageView2: UIImageView!
    @IBOutlet private weak var numberOfImagesLabel: UILabel!
    @IBOutlet private weak var viewGalleryButton: UIButton!

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
        // Always clear the previous images so there are no stale or unexpected image
        // momentarily visible.
        reset()

        let size = CGSize(width:self.galleryImageView1.frame.width, height:self.galleryImageView1.frame.height)
        for item in contentProvider.galleryImages() {

            let galleryImageURL = NSURL(string: item as! String)
            if !(contentProvider.isPrivate()) {
                let url = PhotonImageURLHelper.photonURLWithSize(size, forImageURL: galleryImageURL)
                galleryImageView1.setImageWithURL(url, placeholderImage:nil)

            } else if (galleryImageURL!.host != nil) && galleryImageURL!.host!.hasSuffix("wordpress.com") {
                // private wpcom image needs special handling.
                let url = WPImageURLHelper.imageURLWithSize(size, forImageURL: galleryImageURL!)
                let request = requestForURL(url)
                galleryImageView1.setImageWithURLRequest(request, placeholderImage: nil, success: nil, failure: nil)

            } else {
                // private but not a wpcom hosted image
                galleryImageView1.setImageWithURL(galleryImageURL!, placeholderImage:nil)
            }
        }

        configureButtonForGalleryTitle()
        numberOfImagesLabel.attributedText = attributedTextForGalleryCount(contentProvider.galleryImages().count)
    }

    private func requestForURL(url:NSURL) -> NSURLRequest {
        var requestURL = url

        let absoluteString = requestURL.absoluteString
        if !(absoluteString!.hasPrefix("https")) {
            let sslURL = absoluteString!.stringByReplacingOccurrencesOfString("http", withString: "https")
            requestURL = NSURL(string: sslURL)!
        }

        let request = NSMutableURLRequest(URL: requestURL)

        let acctServ = AccountService(managedObjectContext: ContextManager.sharedInstance().mainContext)
        if let account = acctServ.defaultWordPressComAccount() {
            let token = account.authToken
            let headerValue = String(format: "Bearer %@", token)
            request.addValue(headerValue, forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func attributedTextForGalleryCount(pictureCount:Int) -> NSAttributedString? {
        let attrStr = NSMutableAttributedString()

        let imagesStr = NSLocalizedString("images",
                                         comment: "Part of a label letting the user know how many images are in a image gallery. For example: '6 images'")

        let fullStr = String(format: "%d %@ ", pictureCount, imagesStr)
        let attributes = WPStyleGuide.readerCardWordCountAttributes() as! [String: AnyObject]
        let attrImageCount = NSAttributedString(string: fullStr, attributes: attributes)
        attrStr.appendAttributedString(attrImageCount)

        return attrStr
    }

    private func configureButtonForGalleryTitle() {
        let galleryTitleStr = NSLocalizedString("View Images",
                                          comment: "Label for a button that the user presses to view an image gallery.")

        viewGalleryButton.setTitle(galleryTitleStr, forState: .Normal)
        WPStyleGuide.applyReaderCardTagButtonStyle(viewGalleryButton)
    }
}
