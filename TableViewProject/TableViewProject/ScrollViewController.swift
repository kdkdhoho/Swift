import UIKit

class ScrollViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var url: URL?
    
    override func loadView() {
        super.loadView()
        
        scrollView.backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
        
        scrollView.clipsToBounds = true
        
//        imageView.center = scrollView.center
        
//        loadImage()
//        setImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadImage()
        setImageView()
    }
    
    func loadImage() {
        do {
            let data = try Data(contentsOf: url!)
            imageView.image = UIImage(data: data)
            setImageView()
        } catch {
            print("<Fail func 'loadImage()'> : ", error.localizedDescription)
        }
    }
    
    func loadImage(completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
//            print("<response>: \(String(describing: response))")
            
            if let error = error {
                completion(nil, error)
                return
            }
            if let data = data {
                completion(data, nil)
            } else {
                completion(nil, nil)
            }
        })
    
        task.resume()
    }
    
    func setImageView() {
//        scrollView.contentMode = .scaleAspectFit
//        imageView.sizeToFit()
        scrollView.contentSize = CGSize(width: imageView.image?.size.width ?? 0, height: imageView.image?.size.height ?? 0)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        if scrollView.zoomScale < 1.0 {
//            scrollView.setZoomScale(1.0, animated: true)
//        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width)*0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height)*0.5, 0.0)

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
