//
//  ViewController.swift
//  TestTask
//
//  Created by Дмитрий Болучевских on 01.04.2022.
//

import UIKit
import SnapKit

class MainScreenViewController: UIViewController {
    
    private var tags: [Coctail] = []
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    let font = UIFont.boldSystemFont(ofSize: 14)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTags()
        initialize()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(sender:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(sender:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Init main elements
    private func initialize() {
        view.backgroundColor = .white
        
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.backgroundColor = .white
            scrollView.accessibilityIdentifier = "scrollview"
            return scrollView
        }()
        
        let searchInTags: UITextField = {
            let textField = UITextField()
            textField.accessibilityIdentifier = "searchInTags"
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 15
            textField.placeholder = "Coctail name"
            textField.textAlignment = .center
            textField.font = UIFont.boldSystemFont(ofSize: 15)
            
            textField.layer.shadowOpacity = 1
            textField.layer.shadowRadius = 2.5
            textField.layer.shadowOffset = CGSize(width: 0, height: 3)
            textField.layer.shadowColor = UIColor.gray.cgColor
            
            textField.addTarget(self, action: #selector(searchDrinksWith), for: .editingChanged)
            
            return textField
        }()
        
        view.addSubview(scrollView)
        view.addSubview(searchInTags)
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(50)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        searchInTags.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scrollView.snp_bottomMargin).offset(20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(30)
        }
    }
}

// MARK: = Work with api
extension MainScreenViewController {
    private func getTags() {
        ApiCaller.shared.getNonAlc { [weak self] result in
            switch result {
            case .success(let drinks):
                if let strongSelf = self {
                    strongSelf.tags = drinks.drinks
                    strongSelf.makeTagCloud(onView: strongSelf.view, withCoctails: strongSelf.tags)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Tag cloud's methods
extension MainScreenViewController {
    func makeTagCloud(onView view: UIView, withCoctails coctails: [Coctail]) {
        
        var xPos = 15
        var yPos = 8
        var tag = 0
        let spacing = 8
        let height = 30
        let backgroundColor = UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1)
        
        if let scrollView = view.subviews.first(where: {$0.accessibilityIdentifier == "scrollview"}) as? UIScrollView {
            for coctail in coctails {
                let coctailName = coctail.strDrink
                
                let width = coctailName.widthOfString(usingFont: font)
                
                if CGFloat(xPos) + width > UIScreen.main.bounds.size.width - 30 {
                    xPos = 15
                    yPos += (spacing + height)
                }
                
                let tagBackground: UIButton = {
                    let button = UIButton()
                    button.layer.cornerRadius = 10
                    button.setTitle(coctailName, for: .normal)
                    button.titleLabel?.font = font
                    button.backgroundColor = backgroundColor
                    
                    button.setTitleColor(.white, for: [.normal, .selected])
                    
                    button.tag = tag
                    button.addTarget(self, action: #selector(changeState), for: .touchUpInside)
                    return button
                }()
                
                scrollView.addSubview(tagBackground)
                
                tagBackground.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(xPos)
                    make.top.equalToSuperview().offset(yPos)
                    make.width.equalTo(width + 20)
                    make.height.equalTo(height)
                }
                
                tag += 1
                xPos += Int(width) + spacing + 20
            }
            scrollView.contentSize = CGSize(width: 0, height: yPos + height + spacing)
        }
    }
    
    @objc private func changeState(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            let red = CGColor(srgbRed: 255/255, green: 85/255, blue: 100/255, alpha: 1)
            let purple = CGColor(srgbRed: 255/255, green: 94/255, blue: 252/255, alpha: 1)
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = sender.bounds
            gradient.colors = [red, purple]
            gradient.locations = [0.0, 0.5, 1.0]
            gradient.cornerRadius = 10
            gradient.name = "gradient"
            
            sender.layer.insertSublayer(gradient, at: 0)
        } else {
            if let firstIndex = sender.layer.sublayers?.firstIndex(where: {$0.name == "gradient"}) {
                sender.layer.sublayers?.remove(at: firstIndex)
            }
        }
    }
}

// MARK: - Keyboard's methods
extension MainScreenViewController {
    @objc func keyboardWillShow(sender: NSNotification) {
        if let scrollView = view.subviews.first(where: {$0.accessibilityIdentifier == "scrollview"}) as? UIScrollView,
           let searchInTags = view.subviews.first(where: {$0.accessibilityIdentifier == "searchInTags"}) as? UITextField,
           let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            UIView.animate(withDuration: 1) {
                self.updateContraints(textField: searchInTags, scrollView: scrollView, keyboardHeight: keyboardHeight, keyboardWillPresent: true)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if let scrollView = view.subviews.first(where: {$0.accessibilityIdentifier == "scrollview"}) as? UIScrollView,
           let searchInTags = view.subviews.first(where: {$0.accessibilityIdentifier == "searchInTags"}) as? UITextField,
           let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            UIView.animate(withDuration: 3.0) {
                self.updateContraints(textField: searchInTags, scrollView: scrollView, keyboardHeight: keyboardHeight, keyboardWillPresent: false)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func updateContraints(textField: UITextField, scrollView: UIScrollView, keyboardHeight: CGFloat, keyboardWillPresent: Bool) {
        if keyboardWillPresent {
            scrollView.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(0)
                make.top.equalToSuperview().offset(50)
                make.width.equalToSuperview()
                make.height.equalTo(view.bounds.height - keyboardHeight - 30 - 50)
            }
            
            textField.snp.remakeConstraints { make in
                make.bottom.equalTo(-keyboardHeight)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(30)
            }
            
            textField.layer.cornerRadius = 0
        } else {
            scrollView.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(0)
                make.top.equalToSuperview().offset(50)
                make.width.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.6)
            }
            
            textField.snp.removeConstraints()
            textField.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(scrollView.snp_bottomMargin).offset(20)
                make.width.equalToSuperview().multipliedBy(0.8)
                make.height.equalTo(30)
            }
            textField.layer.cornerRadius = 15
        }
    }
}

// MARK: - Search's methods
extension MainScreenViewController {
    @objc func searchDrinksWith(textField: UITextField) {
        if let searchText = textField.text?.lowercased() {
            for index in 0..<tags.count {
                if let scrollview = view.subviews.first(where: { $0.accessibilityIdentifier == "scrollview" }),
                   let neededTag = scrollview.subviews.first(where: { $0.tag == index }) as? UIButton {
                    if tags[index].strDrink.lowercased().contains(searchText) {
                        if !neededTag.isSelected {
                            changeState(sender: neededTag)
                        }
                    } else {
                        if neededTag.isSelected {
                            changeState(sender: neededTag)
                        }
                    }
                }
            }
        }
    }
}
