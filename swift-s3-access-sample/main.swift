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

let fileUrl = URL(fileURLWithPath: testFile)
let fileExtension = fileUrl.pathExtension
guard let nameHash = testFile.data(using: .utf8),
   let fileData = try? Data(contentsOf: fileUrl) else {
	print("Failed to load file or hash file path.")
	exit(-2)
}
let fileName = SHA256.hash(data: nameHash).hexDigest() + "." + fileExtension

// S3 Operations Start Here

let client = AWSClient(credentialProvider: .static(accessKeyId: accessKey, secretAccessKey: accessSecret), httpClientProvider: .createNew)
//let s3 = S3(client: client, region: .useast1) // AWS S3
let s3 = S3(client: client, endpoint: storageEndpoint) // MinIO

do {
	let putRequest = S3.PutObjectRequest(body: .data(fileData), bucket: bucketName, key: fileName)
	let putResult = try await s3.putObject(putRequest).get()
	print("Stored as \(fileName) \(putResult.eTag ?? "X").")
	
	let getRequest = S3.GetObjectRequest(bucket: bucketName, key: fileName)
	let getResult = try await s3.getObject(getRequest).get()
	print("Info: \(getResult.contentType ?? "") \(getResult.contentLength ?? 0)")
	
	let deleteRequest = S3.DeleteObjectRequest(bucket: bucketName, key: fileName)
	let _ = try await s3.deleteObject(deleteRequest).get()
	print("\(fileName) removed.")
} catch {
	print("ERROR: \(error)")
}
