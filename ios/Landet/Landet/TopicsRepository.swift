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
            commentsRepository.loadInitial()
        }
    }

    let commentsRepository = TopicCommentsRepository()

    func load(callback: ((error: NSError?) -> ())? = nil) {

        let op = AsyncOperation()
        op.asyncTask = { completion in

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

                    completion()
                    callback?(error: error)
                }
            }
        }

        NSOperationQueue.mainQueue().addOperation(op)
    }

    func create(topicText text: String, callback:( error: NSError?) -> ()) {
        TopicAPI.shared.create(title: text) { (error) in
            if let error = error {
                callback(error: error)
            } else {
                self.load(callback)
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

    private var topicToComments = [Int : [TopicComment]]()
    private var topicToHasMore = [Int : Bool]()

    private var topic: Topic! {
        didSet {
            delegate?.repository(self, didChangeToTopic: topic)
        }
    }

    var comments: [TopicComment] {
        guard let topic = topic else { return [] }
        return topicToComments[topic.id] ?? []
    }
    var canLoadMore: Bool {
        guard let topic = topic else { return false }
        return topicToHasMore[topic.id] ?? false
    }

    func loadInitial() {
        if comments.count < 10 {
            loadNextPage()
        }
    }

    func loadNextPage() {

        let op = AsyncOperation()
        op.asyncTask = { completion in

            let before = self.topicToComments[self.topic.id]?.last?.timestamp

            TopicAPI.shared.comments(forTopic: self.topic, before: before, orAfter: nil) { [weak self] (comments, hasMore, error) in
                Async.main {
                    guard let strongSelf = self else { return }

                    if let e = error {
                        print(e)
                    }
                    else if let comments = comments {
                        var existing = strongSelf.topicToComments[strongSelf.topic.id] ?? []
                        let oldCount = existing.count

                        existing.appendContentsOf(comments)
                        let newCount = existing.count

                        strongSelf.topicToComments[strongSelf.topic.id] = existing
                        strongSelf.topicToHasMore[strongSelf.topic.id] = hasMore

                        strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (oldCount..<newCount))
                    }

                    completion()
                }
            }
        }

        NSOperationQueue.mainQueue().addOperation(op)
    }

    func loadNewComments() {

        let op = AsyncOperation()
        op.asyncTask = { completion in

            let after = self.topicToComments[self.topic.id]?.first?.timestamp

            TopicAPI.shared.comments(forTopic: self.topic, before: nil, orAfter: after) { [weak self] (comments, hasMore, error) in
                Async.main {
                    guard let strongSelf = self else { return }

                    if let e = error {
                        print(e)
                    }
                    else if let comments = comments {
                        var existing = strongSelf.topicToComments[strongSelf.topic.id] ?? []
                        existing.insertContentsOf(comments, at: 0)

                        strongSelf.topicToComments[strongSelf.topic.id] = existing

                        strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (0..<comments.count))
                    }

                    completion()
                }
            }
        }

        NSOperationQueue.mainQueue().addOperation(op)
    }

    func post(comment comment: String, toTopic topic: Topic) {
        TopicAPI.shared.post(comment: comment, toTopic: topic) { [weak self] (error) in
            self?.loadNewComments()
        }
    }
}
