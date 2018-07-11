//
//  ListViewController.swift
//  Chapter05-CustomPlist
//
//  Created by Jonghwi Lee on 2018. 7. 10..
//  Copyright © 2018년 Jonghwi Lee. All rights reserved.
//

import Foundation
import UIKit

class ListViewController : UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var account: UITextField!
    @IBOutlet var name: UILabel!
    @IBOutlet var gender: UISegmentedControl!
    @IBOutlet var married: UISwitch!
    
    var accountlist = [String]()
    
    override func viewDidLoad() {
        let picker = UIPickerView()
        
        // 1. 피커 뷰의 델리게이트 객체 지정
        picker.delegate = self
        
        // 2. account 텍스트 필드 입력 방식을 가상 키보드 대신 피커 뷰로 설정
        self.account.inputView = picker
        
        // 툴 바 객체 정의
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = UIColor.lightGray
        
        // 액세서리 뷰 영역에 툴 바를 표시
        self.account.inputAccessoryView = toolbar
        
        // 툴 바에 들어갈 닫기 버튼
        let done = UIBarButtonItem()
        done.title = "Done"
        done.target = self
        done.action = #selector(pickerDone)
        
        // 추가 1. 가변 폭 버튼 정의
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 추가) 신규 계정 등록 버튼
        let new = UIBarButtonItem()
        new.title = "New"
        new.target = self
        new.action = #selector(newAccount(_:))
        
        // 버튼을 툴 바에 추가
        toolbar.setItems([new, flexSpace, done], animated: true)
        
        // 기본 저장소 객체 불러오기
        let plist = UserDefaults.standard
        
        // 불러온 값을 설정
        self.name.text = plist.string(forKey: "name")
        self.married.isOn = plist.bool(forKey: "married")
        self.gender.selectedSegmentIndex = plist.integer(forKey: "gender")
        
        let accountlist = plist.array(forKey: "accountlist") as? [String] ?? [String]()
        self.accountlist = accountlist
        
        if let account = plist.string(forKey: "selectedAccount") {
            self.account.text = account
        }
    }
    
    // 생성할 컴포넌트 개수를 정의.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 지정된 컴포넌트가 가질 목록의 길이를 정의.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return self.accountlist.count
    }
    
    // 지정된 컴포넌트의 목록 각 행에 출력될 내용을 정의.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.accountlist[row]
    }
    
    // 지정된 컴포넌트의 목록 각 행을 사용자가 선택했을 때 실행할 액션을 정의.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 1. 선택된 계정값을 텍스트 필드에 입력
        let account = self.accountlist[row]
        self.account.text = account
        
        // 2. 입력 뷰를 닫음
        //self.view.endEditing(true) => Done 버튼 추가로 삭제
        
        // 계정 생성시 계정을 선택한 것으로 간주하고 저장
        let plist = UserDefaults.standard
        
        plist.set(account, forKey: "selectedAccount")
        plist.synchronize()
    }
    
    @objc func pickerDone(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func newAccount(_ sender: Any) {
        self.view.endEditing(true)
        
        // 알림창 객체 생성
        let alert = UIAlertController(title: "새 계정을 입력하세요.", message: nil, preferredStyle: .alert)
        
        // 입력폼 추가
        alert.addTextField() {
            $0.placeholder = "ex) aaa@naver.com"
        }
        
        // 버튼 및 액션 정의
        alert.addAction(UIAlertAction(title: "OK", style: .default) {(_) in
            if let account = alert.textFields?[0].text {
                // 계정 목록에 추가
                self.accountlist.append(account)
                // 계정 텍스트 필드에 표시
                self.account.text = account
                
                let plist = UserDefaults.standard
                
                plist.set(self.accountlist, forKey: "accountlist")
                plist.set(account, forKey: "selectedAccount")
                plist.synchronize()
            }
            
            // 컨트롤 값을 모두 초기화한다.
            //self.name.text = ""
            //self.gender.selectedSegmentIndex = 0
            //self.married.isOn = false
        })
        // 알림창 오픈
        self.present(alert, animated: false, completion: nil)
    }
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex // 0=남자, 1=여자
        
        let plist = UserDefaults.standard
        plist.set(value, forKey: "gender")
        plist.synchronize()
    }
    @IBAction func changeMarried(_ sender: UISwitch) {
        let value = sender.isOn
        
        let plist = UserDefaults.standard
        plist.set(value, forKey: "married")
        plist.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 { // 두 번째 셀 클릭시
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요.", preferredStyle: .alert)
            // 입력 필드 추가
            alert.addTextField() {
                $0.text = self.name.text
            }
            
            // 버튼 및 액션 추가
            alert.addAction(UIAlertAction(title: "OK", style: .default) {
                (_) in
                // OK 버튼을 누르면 입력 필드에 입력된 값을 저장.
                let value = alert.textFields?[0].text
                
                let plist = UserDefaults.standard
                plist.setValue(value, forKey: "name")
                plist.synchronize()
                
                self.name.text = value
            })
            
            // 알림창 띄움
            self.present(alert, animated: false, completion: nil)
        }
    }
}
