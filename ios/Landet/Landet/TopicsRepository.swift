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
            commentsRepository.loadIntitial(forTopic: topic)
            delegate?.repositoryChangedTopic(self)
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
    func repository(repository: TopicCommentsRepository, loadedNewCommentsInRange range: Range<Int>)
}

class TopicCommentsRepository {

    weak var delegate: TopicCommentsRepositoryDelegate?

    private(set) var comments = [Int : [TopicComment]]()

    func loadIntitial(forTopic topic: Topic) {
        TopicAPI.shared.comments(forTopic: topic, before: nil, orAfter: nil) { [weak self] (comments, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let comments = comments {
                    strongSelf.comments[topic.id] = comments
                    strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (0..<comments.count))
                }
            }
        }
    }

    func loadNextPage(forTopic topic: Topic) {

        let before = comments[topic.id]?.last?.timestamp

        TopicAPI.shared.comments(forTopic: topic, before: before, orAfter: nil) { [weak self] (comments, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let comments = comments {
                    let oldCount = strongSelf.comments[topic.id]!.count
                    let newCount = oldCount + comments.count

                    strongSelf.comments[topic.id]?.appendContentsOf(comments)
                    strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (oldCount..<newCount))
                }
            }
        }
    }

    func loadNewComments(forTopic topic: Topic) {

        let after = comments[topic.id]?.first?.timestamp

        TopicAPI.shared.comments(forTopic: topic, before: nil, orAfter: after) { [weak self] (comments, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let comments = comments {
                    strongSelf.comments[topic.id]?.insertContentsOf(comments, at: 0)
                    strongSelf.delegate?.repository(strongSelf, loadedNewCommentsInRange: (0..<comments.count))
                }
            }
        }
    }

    func post(comment comment: String, toTopic topic: Topic) {
        TopicAPI.shared.post(comment: comment, toTopic: topic) { [weak self] (error) in
            self?.loadNewComments(forTopic: topic)
        }
    }
}
