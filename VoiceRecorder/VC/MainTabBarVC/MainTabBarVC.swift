//
//  MainTabBarVC.swift
//  VoiceRecorder
//
//  Created by 김민지 on 1/6/26.
//

import UIKit

final class MainTabBarVC: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()
    setupVC()
  }
  
  private func setupTabBar() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .systemBackground
    
    appearance.stackedLayoutAppearance.normal.iconColor = .darkGray
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
    appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
    
    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
  }
  
  private func setupVC() {
    let recordingVC = RecordingVC()
    recordingVC.tabBarItem = UITabBarItem(title: "녹음", image: UIImage(systemName: "mic"), selectedImage: UIImage(systemName: "mic.fill"))
    
    let listVC = ListVC()
    listVC.tabBarItem = UITabBarItem(title: "목록", image: UIImage(systemName: "text.document"), selectedImage: UIImage(systemName: "text.document.fill"))
    
    viewControllers = [recordingVC, listVC]
  }
}

