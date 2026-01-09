//
//  MainTabBarViewController.swift
//  VoiceRecorder
//
//  Created by 김민지 on 1/6/26.
//  탭바 컨트롤러 (녹음/목록 탭)

import UIKit

final class MainTabBarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()
    setupVC()
  }
  
  private func setupTabBar() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .customBlack
    
    appearance.stackedLayoutAppearance.normal.iconColor = .customGray
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.customGray]
    appearance.stackedLayoutAppearance.selected.iconColor = .customPurple
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.customPurple]
    
    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
  }
  
  private func setupVC() {
    let recordingVC = RecordingViewController()
    recordingVC.tabBarItem = UITabBarItem(title: "녹음", image: UIImage(systemName: "mic"), selectedImage: UIImage(systemName: "mic.fill"))
    
    let listVC = RecordingListViewController()
    listVC.tabBarItem = UITabBarItem(title: "목록", image: UIImage(systemName: "text.document"), selectedImage: UIImage(systemName: "text.document.fill"))
    
    viewControllers = [recordingVC, listVC]
  }
}

