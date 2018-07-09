//
//  ExtensionViewController.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 25/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import UIKit

extension ViewController: FileProviderDelegate {
        func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
            switch operation {
            case .copy(let source, let destination):
                print("Copy fileproviderSucceed - source: \(source) - destination: \(destination)")
            case .create(let path):
                print("Create fileproviderSucceed - filePath: \(path)")
            case .modify(let path):
                print("Modify fileproviderSucceed - filePath: \(path)")
                DispatchQueue.main.async {
                    alertDismissProgressbar(self)
                }
            default:
                break
            }
        }
    
        func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
            switch operation {
            case .copy(let source, let destination):
                print("Copy fileproviderFailed - source: \(source) - destination: \(destination) - error: \(error.localizedDescription)")
            case .create(let path):
                print("Create fileproviderFailed - filePath: \(path) - error: \(error.localizedDescription)")
                if let error = error as? FileProviderWebDavError {
                    switch error.code {
                    case .unauthorized:
                        print("Non autorizzato. Modificare le credenziali.")
                        return
                    default:
                        print("Errore webdavFile: \(String(describing: error.errorDescription))")
                        return
                    }
                }
            case .modify(let path):
                print("Modify fileproviderFailed - filePath: \(path) - error: \(error.localizedDescription)")
            default:
                break
            }
        }
    
        func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
            switch operation {
            case .create(let path):
                print("Create fileproviderProgress - filePath: \(path) - Progress: \(progress)")
                DispatchQueue.main.async {
                    self.progressBar.setProgress(progress, animated: true)
                }
            case .modify( _):
    //            print("Modify fileproviderProgress - filePath: \(path) - Progress: \(progress)")
                DispatchQueue.main.async {
                    self.progressBar.setProgress(progress, animated: true)
                }        case .remove(let path):
                print("Remove fileproviderProgress - filePath: \(path) - Progress: \(progress)")
                progressBar.setProgress(progress, animated: true)
            case .fetch(let path):
                print("Fetch fileproviderProgress - filePath: \(path) - Progress: \(progress)")
                DispatchQueue.main.async {
                    self.progressBar.setProgress(progress, animated: true)
                }
            default:
                break
            }
        }
    }
