//
//  ManagedCache+CoreDataClass.swift
//  Tests
//
//  Created by JL Dev on 2/12/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData
import FeedStoreChallenge

@objc(ManagedCache)
public class ManagedCache: NSManagedObject {

}

extension ManagedCache {
	var localFeed: [LocalFeedImage] {
		feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
}
