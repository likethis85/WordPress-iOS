import Foundation
import WordPressShared

@objc public class ReaderCardGalleryStripView: UIView
{
    @IBOutlet private weak var galleryImageCollectionView: UICollectionView!
    @IBOutlet private weak var numberOfImagesLabel: UILabel!
    @IBOutlet private weak var viewGalleryButton: UIButton!

    private var modell:[[UIColor]] = []
    private var storedOffsets = [Int: CGFloat]()

    // MARK: - Lifecycle Methods

    public override func awakeFromNib() {
        super.awakeFromNib()
        
        // Register the colleciton cell
        let nibName = UINib(nibName: "ReaderCardGalleryStripCell", bundle:nil)
        galleryImageCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "GalleryStripCell")
    }

    // MARK: - Configuration

    public func configureView(contentProvider: ReaderPostContentProvider?) {

        guard let cp = contentProvider else {
            reset()
            return
        }

        modell = generateRandomBunkData()

        configureGalleryImageStrip(cp)
        invalidateIntrinsicContentSize()
    }

    var collectionViewOffset: CGFloat {
        set {
            galleryImageCollectionView.contentOffset.x = newValue
        }

        get {
            return galleryImageCollectionView.contentOffset.x
        }
    }

    private func reset() {
        galleryImageCollectionView.reloadData()
    }

    private func configureGalleryImageStrip(contentProvider: ReaderPostContentProvider) {
        setCollectionViewDataSourceDelegate(self)

//        let size = CGSize(width:self.galleryImageView1.frame.width, height:self.galleryImageView1.frame.height)
//        for item in contentProvider.galleryImages() {
//
//            let galleryImageURL = NSURL(string: item as! String)
//            if !(contentProvider.isPrivate()) {
//                let url = PhotonImageURLHelper.photonURLWithSize(size, forImageURL: galleryImageURL)
//                galleryImageView1.setImageWithURL(url, placeholderImage:nil)
//
//            } else if (galleryImageURL!.host != nil) && galleryImageURL!.host!.hasSuffix("wordpress.com") {
//                // private wpcom image needs special handling.
//                let url = WPImageURLHelper.imageURLWithSize(size, forImageURL: galleryImageURL!)
//                let request = requestForURL(url)
//                galleryImageView1.setImageWithURLRequest(request, placeholderImage: nil, success: nil, failure: nil)
//
//            } else {
//                // private but not a wpcom hosted image
//                galleryImageView1.setImageWithURL(galleryImageURL!, placeholderImage:nil)
//            }
//        }

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

    private func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D) {
        galleryImageCollectionView.delegate = dataSourceDelegate
        galleryImageCollectionView.dataSource = dataSourceDelegate
        galleryImageCollectionView.setContentOffset(galleryImageCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        reset()
    }

    private func generateRandomBunkData() -> [[UIColor]] {
        let numberOfRows = 20
        let numberOfItemsPerRow = 15

        return (0..<numberOfRows).map { _ in
            return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
        }
    }
}

extension UIColor {
    class func randomColor() -> UIColor {

        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

extension ReaderCardGalleryStripView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modell[collectionView.tag].count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryStripCell", forIndexPath: indexPath)

        cell.backgroundColor = modell[collectionView.tag][indexPath.item]

        return cell
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
