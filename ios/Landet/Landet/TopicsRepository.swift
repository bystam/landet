//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

protocol TopicsRepositoryDelegate: class {
    func repositoryLoadedTopics(repository: TopicsRepository)
    func repositoryChangedTopic(repository: TopicsRepository)
}

class TopicsRepository {

    weak var delegate: TopicsRepositoryDelegate?

    private(set) var topics = [Topic]()
    var currentTopic: Topic? {
        didSet {
            guard let topic = currentTopic where topic !== oldValue else { return }

            delegate?.repositoryChangedTopic(self)

            commentsRepository.topic = topic
            commentsRepository.loadNewComments()
        }
    }

    let commentsRepository = TopicCommentsRepository()

    func load() {
        TopicAPI.shared.loadAll { [weak self] (topics, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let topics = topics {
                    strongSelf.topics = topics
                    strongSelf.delegate?.repositoryLoadedTopics(strongSelf)
                }
            }
        }
    }
}


protocol TopicCommentsRepositoryDelegate: class {
    func repository(repository: TopicCommentsRepository, didChangeToTopic topic: Topic)
    func repository(repository: TopicCommentsRepository, loadedNewCommentsInRange range: Range<Int>)
}

class TopicCommentsRepository {

    weak var delegate: TopicCommentsRepositoryDelegate?

    private(set) var comments = [Int : [TopicComment]]()
    private var topic: Topic! {
        didSet {
            delegate?.repository(self, didChangeToTopic: topic)
        }
    }

    func loadNextPage() {

        let before = comments[topic.id]?.last?.timestamp

        TopicAPI.shared.comments(forTopic: topic, before: before, orAfter: nil) { [weak self] (comments, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let comments = comments {
                    let oldCount = strongSelf.comments[strongSelf.topic.id]!.count
                    let newCount = oldCount + comments.count

                    strongSelf.comments[strongSelf.topic.id]?.appendContentsOf(comments)
                    strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (oldCount..<newCount))
                }
            }
        }
    }

    func loadNewComments() {

        let after = comments[topic.id]?.first?.timestamp

        TopicAPI.shared.comments(forTopic: topic, before: nil, orAfter: after) { [weak self] (comments, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let comments = comments {
                    var existing = strongSelf.comments[strongSelf.topic.id] ?? []
                    existing.insertContentsOf(comments, at: 0)

                    strongSelf.comments[strongSelf.topic.id] = existing
                    strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (0..<comments.count))
                }
            }
        }
    }

    func post(comment comment: String, toTopic topic: Topic) {
        TopicAPI.shared.post(comment: comment, toTopic: topic) { [weak self] (error) in
            self?.loadNewComments()
        }
    }
}
