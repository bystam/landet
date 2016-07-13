//
//  Copyright © 2016 Landet. All rights reserved.
//

import Foundation

protocol TopicsRepositoryDelegate: class {
    func repository(repository: TopicsRepository, loadedTopics topics: [Topic]?)
    func repository(repository: TopicsRepository, changedToTopic topic: Topic?)
}

class TopicsRepository {

    weak var delegate: TopicsRepositoryDelegate?

    private(set) var topics: [Topic]?
    var currentTopic: Topic? {
        didSet {
            guard currentTopic !== oldValue else { return }

            delegate?.repository(self, changedToTopic: currentTopic)

            commentsRepository.topic = currentTopic

            if currentTopic != nil {
                commentsRepository.loadInitial()
            }
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
                        if strongSelf.currentTopic == nil {
                            strongSelf.currentTopic = topics.first
                        }

                        strongSelf.delegate?.repository(strongSelf, loadedTopics: topics)
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
    func repository(repository: TopicCommentsRepository, didChangeToTopic topic: Topic?)
    func repository(repository: TopicCommentsRepository, loadedNewCommentsInRange range: Range<Int>)
}

class TopicCommentsRepository {

    weak var delegate: TopicCommentsRepositoryDelegate?

    private var topicToComments = [Int : [TopicComment]]()
    private var topicToHasMore = [Int : Bool]()

    private var topic: Topic? {
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
        if comments.isEmpty {
            loadNextPage()
        } else {
            loadNewComments()
        }
    }

    func loadNextPage() {

        guard let topic = topic else { return }

        let op = AsyncOperation()
        op.asyncTask = { completion in

            let before = self.topicToComments[topic.id]?.last?.timestamp

            TopicAPI.shared.comments(forTopic: topic, before: before, orAfter: nil) { [weak self] (comments, hasMore, error) in
                Async.main {
                    guard let strongSelf = self else { return }

                    if let e = error {
                        print(e)
                    }
                    else if let comments = comments {
                        var existing = strongSelf.topicToComments[topic.id] ?? []
                        let oldCount = existing.count

                        existing.appendContentsOf(comments)
                        let newCount = existing.count

                        strongSelf.topicToComments[topic.id] = existing
                        strongSelf.topicToHasMore[topic.id] = hasMore

                        if strongSelf.topic === topic {
                            strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (oldCount..<newCount))
                        }
                    }

                    completion()
                }
            }
        }

        NSOperationQueue.mainQueue().addOperation(op)
    }

    func loadNewComments() {

        guard let topic = topic else { return }

        let op = AsyncOperation()
        op.asyncTask = { completion in

            let after = self.topicToComments[topic.id]?.first?.timestamp

            TopicAPI.shared.comments(forTopic: topic, before: nil, orAfter: after) { [weak self] (comments, hasMore, error) in
                Async.main {
                    guard let strongSelf = self else { return }

                    if let e = error {
                        print(e)
                    }
                    else if let comments = comments {
                        var existing = strongSelf.topicToComments[topic.id] ?? []
                        existing.insertContentsOf(comments, at: 0)

                        strongSelf.topicToComments[topic.id] = existing

                        if strongSelf.topic === topic {
                            strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (0..<comments.count))
                        }
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
