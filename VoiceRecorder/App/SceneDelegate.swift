//
//  SceneDelegate.swift
//  VoiceRecorder
//
//  Created by 김민지 on 1/6/26.
//  씬 생명주기, 루트 뷰 설정

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = MainTabBarViewController()
    window?.makeKeyAndVisible()
  }
}

