import UIKit
import WebKit

class WebViewController: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    var urlStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlStr = urlStr {
            let requestURL = URL(string: urlStr)
            let request = URLRequest(url: requestURL!)
            
            webView.load(request)
        }
    }
}
