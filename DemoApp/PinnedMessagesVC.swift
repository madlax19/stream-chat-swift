//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatUI
import UIKit

final class PinnedMessagesVC: UITableViewController {
    var channelController: ChatChannelController!
    
    private lazy var loadMoreButton = UIBarButtonItem(
        image: UIImage(systemName: "square.and.arrow.down")!,
        style: .plain,
        target: self,
        action: #selector(loadMore)
    )
    
    private var pinnedMessages: [ChatMessage] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = loadMoreButton
        
        loadMore()
    }
    
    // MARK: - UITableViewDelegate & Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pinnedMessages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = pinnedMessages[indexPath.row]
        
        let cell: UITableViewCell = {
            let reuseIdentifier = "cell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                return UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            }
            return cell
        }()
        
        cell.textLabel?.text = message.textContent
        cell.detailTextLabel?.text = message.pinDetails?.pinnedAt.description
        return cell
    }
    
    @objc private func loadMore() {
        let pagination: PinnedMessagesPagination? = pinnedMessages.last.map { .before($0.id, inclusive: false) }
        
        channelController.loadPinnedMessages(
            pageSize: 5,
            pagination: pagination,
            completion: {
                switch $0 {
                case let .success(messages):
                    self.pinnedMessages.append(contentsOf: messages)
                case let .failure(error):
                    log.error(error.localizedDescription)
                }
            }
        )
    }
}
