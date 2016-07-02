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
            commentsRepository.load(forTopic: topic)
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
    func repositoryLoadedComments(repository: TopicCommentsRepository)
}

class TopicCommentsRepository {

    weak var delegate: TopicCommentsRepositoryDelegate?

    private(set) var comments = [Int : [TopicComment]]()

    private func load(forTopic topic: Topic) {
        TopicAPI.shared.comments(forTopic: topic) { [weak self] (comments, error) in
            Async.main {
                guard let strongSelf = self else { return }

                if let e = error {
                    print(e)
                }
                else if let comments = comments {
                    strongSelf.comments[topic.id] = comments
                    strongSelf.delegate?.repositoryLoadedComments(strongSelf)
                }
            }
        }
    }

    func post(comment comment: String, toTopic topic: Topic) {
        TopicAPI.shared.post(comment: comment, toTopic: topic) { [weak self] (error) in
            self?.load(forTopic: topic)
        }
    }
}
