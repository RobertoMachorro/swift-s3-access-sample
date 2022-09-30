//
//  main.swift
//  swift-s3-access-sample
//
//  Created by Roberto Machorro on 9/29/22.
//

import Foundation
import Crypto

import SotoCore
import SotoS3

let env = ProcessInfo.processInfo.environment
guard let accessKey = env["STORAGE_KEY"],
	  let accessSecret = env["STORAGE_SECRET"],
	  let storageEndpoint = env["STORAGE_ENDPOINT"],
	  let bucketName = env["STORAGE_BUCKET"],
	  let testFile = env["TEST_FILE"] else {
	print("Please specify configuration.")
	exit(-1)
}

let client = AWSClient(credentialProvider: .static(accessKeyId: accessKey, secretAccessKey: accessSecret), httpClientProvider: .createNew)
//let s3 = S3(client: client, region: .useast1) // AWS S3
let s3 = S3(client: client, endpoint: storageEndpoint) // MinIO

let fileUrl = URL(fileURLWithPath: testFile)
let fileExtension = fileUrl.pathExtension

if let nameHash = testFile.data(using: .utf8) {
	let sha = SHA256.hash(data: nameHash)
	let fileName = "\(sha).\(fileExtension)"
	print("File: \(fileName)")
}
