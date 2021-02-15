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

@objc(ManagedCache)
class ManagedCache: NSManagedObject {

}

extension ManagedCache {
	var localFeed: [LocalFeedImage] {
		feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
}

extension ManagedCache {
	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let fetchRequest = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		fetchRequest.returnsObjectsAsFaults = false
		
		return try context.fetch(fetchRequest).first
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try find(in: context).map { context.delete($0) }
		return ManagedCache(context: context)
	}
}
