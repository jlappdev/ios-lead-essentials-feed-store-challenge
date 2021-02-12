//
//  ManagedFeedImage+CoreDataClass.swift
//  Tests
//
//  Created by JL Dev on 2/12/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData
import FeedStoreChallenge

@objc(ManagedFeedImage)
public class ManagedFeedImage: NSManagedObject {

}

extension ManagedFeedImage {
	var local: LocalFeedImage {
		LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
