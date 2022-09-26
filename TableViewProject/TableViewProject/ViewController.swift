import UIKit

struct Comment: Codable {
    var id: Int?
    var nickname: String?
    var content: String?
    var data: String?
    var likes: Int?
    var likeStatus: Bool?
    var status: Bool?
    var donationAmount: Int?
    var gender: String?
}

struct Link: Codable {
    var name: String?
}

struct Post: Codable {
    var title: String?
    var subTitle: String?
    var content: String?
    var targetAmount: Int?
    var startDate: String?
    var endDate: String?
    var tag: [Dictionary<String, String>]?
    var link: [Link]?
    var image: String?
    var donation: Dictionary<String, Int>
    var comment: [Comment]?
    var donateCheer: Bool?
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let url: String = "http://valuetogether.tk/fundraisings/1"
    var post: Post?
    
//    var keys: [String] = ["title", "subTitle", "content", "targetAmount", "startDate", "endDate", "tag", "link", "image", "donateCheer", "donation", "comment"]
    var keys: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData(completion: { [weak self] (result, error) in
            if let error = error {
                print("<error>: \(error.localizedDescription)")
            }
            
            if let result = result {
                self?.post = try? JSONDecoder().decode(Post.self, from: result)
                self?.keys = ["title", "subTitle", "content", "targetAmount", "startDate", "endDate", "tag", "link", "image", "donateCheer", "donation", "comment"]
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
    func loadData(completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let url = URL(string: self.url)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
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

    // count of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    // text of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "keyCell", for: indexPath)
        
        cell.textLabel?.text = keys[indexPath.row]
        
        return cell
    }

    // cell click event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let touchedCell = tableView.cellForRow(at: indexPath)
        let cellText = touchedCell?.textLabel?.text
        
        if (cellText == "link") {
            touchLinkCell()
        }
        else if (cellText == "image") {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "scrollViewController") as? ScrollViewController else { return }
            nextVC.url = URL(string: (post?.image)!)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController else { return }
            nextVC.receiveData = setReceiveData(key: cellText)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func touchLinkCell() {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "webViewController") as? WebViewController else { return }
        
//            nextVC.urlStr = post?.link?.first?.name
        nextVC.urlStr = connectWebLink()
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func connectWebLink() -> String? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userInfo = appDelegate.userInfo as! [String: Any]

        if(userInfo["weblink"] as? String == "") {
            return post?.link?.first?.name
        } else {
            return userInfo["weblink"] as? String
        }
    }
    
    func setReceiveData(key: String!) -> Any {
        if(key == "title") {
            return post?.title as Any
        }
        if(key == "subTitle") {
            return post?.subTitle as Any
        }
        if(key == "targetAmount") {
            return post?.targetAmount as Any
        }
        
        return "nothing"
    }
}
