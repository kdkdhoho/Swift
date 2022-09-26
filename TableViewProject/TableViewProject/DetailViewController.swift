import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var result: [String] = []
    
    var receiveData: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell", for: indexPath)
        
        if(receiveData is Int) {
            cell.textLabel?.text = String((receiveData as? Int)!)
        }
        else {
            cell.textLabel?.text = receiveData as? String
        }
        
        return cell
    }
}


