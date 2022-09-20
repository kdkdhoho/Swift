import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    lazy var accessoryView: UIView = {
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 72.0))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextField()
        setUpWebView()
        setUpProgresBar()
        
        button.addTarget(self, action: #selector(touchUpInsideBtn), for: .touchUpInside)
    }
    
    func setUpTextField() {
        textField.text = "https://google.com"
        textField.clearsOnBeginEditing = true
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.delegate = self
        
        accessoryView.addSubview(button)
        textField.inputAccessoryView = accessoryView
    }
    
    @objc func touchUpInsideBtn() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let url: URL? = URL(string: textField.text!)
        if let request = url {
            let result = URLRequest(url: request)
            webView.load(result)
        }
        
        return true
    }
    
    func setUpWebView() {
        self.webView.backgroundColor = UIColor.clear
        self.webView.isOpaque = false
        
        // addObserver로 estimatedPorgress에 대한 이벤트 수신 설정
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new ,context: nil)
    }
    
    func setUpProgresBar() {
        progressBar.setProgress(0.0, animated: true)
        progressBar.isHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if self.webView.estimatedProgress >= 1.0 {
            UIView.animate(withDuration: 0.3, animations: { () in
                self.progressBar.alpha = 0.0
            }, completion: { finished in
                self.progressBar.setProgress(0.0, animated: false)
            })
        } else {
            self.progressBar.isHidden = false
            self.progressBar.alpha = 1.0
            progressBar.setProgress(Float(self.webView.estimatedProgress), animated: true)
        }
    }
    
    deinit {
        // WKWebView Progress 퍼센트 가져오기 이벤트 제거
        self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}
