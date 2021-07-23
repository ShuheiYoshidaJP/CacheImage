//
//  ViewController.swift
//  CacheImage
//
//  Created by 吉田周平 on 2021/07/22.
//

import UIKit
import SwiftUI
import Kingfisher

/// https://blog.mothule.com/ios/uitableview/ios-uitableview-lifecycle

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataManager = DataManager()

    private var items: [Model] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        async {
            await items = dataManager.fetchData()
            tableView.reloadData()
        }
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ret: MyTableViewCell
        let model = items[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? MyTableViewCell {
            ret = cell
        } else {
            ret = MyTableViewCell(style: .default, reuseIdentifier: "cell")
        }
        ret.config(model: model)
        return ret
    }
}

class MyTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("セルが生成されましたー")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        print("セルが再利用されてますー")
    }
    
    func config(model: Model) {
        titleLabel?.text = model.title
        //setImageByUrl(url: model.imageUrl)
        useKingFisher(url: model.imageUrl)
    }
    
    func setImageByUrl(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            imageView?.image = UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
    }
    
    func useKingFisher(url: String) {
        let url = URL(string: url)
        imageView?.kf.setImage(with: url)
    }
}

struct Model: Codable {
    var title: String
    var imageUrl: String
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case imageUrl = "thumbnailUrl"
    }
}

class DataManager {
    let url = URL(string: "https://jsonplaceholder.typicode.com/photos")
    func fetchData() async -> [Model] {
        guard let url = url else {
            return []
        }
        
        let session = URLSession(configuration: .default)
        do {
            let task = try await session.data(from: url)
            let list = try JSONDecoder().decode([Model].self, from: task.0)
            return list
        } catch {
            print("\(error.localizedDescription)")
            return []
        }
    }
}
