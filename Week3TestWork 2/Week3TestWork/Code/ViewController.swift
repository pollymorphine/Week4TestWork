//
//  ViewController.swift
//  Week3TestWork
//
//  Copyright © 2018 E-legion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var bruteForcedTimeLabel: UILabel!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var generatePasswordButton: UIButton!
    
    private let passwordGenerate = PasswordGenerator()
    private let characterArray = Consts.characterArray
    private let maxTextLength = Consts.maxTextFieldTextLength
    private var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        disableStartButton()
        
        //Hide keyboard on screen tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tap)
        inputTextField.delegate = self
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func generatePasswordButtonPressed(_ sender: UIButton) {
        clearText()
        inputTextField.text = passwordGenerate.randomString(length: 4)
        enableStartButton()
    }
    
    @IBAction func startBruteFoceButtonPressed(_ sender: Any) {
        guard let text = inputTextField.text else {
            return
        }
        password = text
        clearText()
        disableStartButton()
        statusLabel.text = "Status: in process"
        indicator.isHidden = false
        indicator.startAnimating()
        generatePasswordButton.isEnabled = false
        generatePasswordButton.alpha = 0.5
        start()
    }
    
    private func bruteForceOperation(password: String) {
        let requiredPassword = password
        let operationQueue = OperationQueue()
        let startTime = Date()
        
        let operation1 = BruteForceOperation(startString: "0000", endString: "dddd", password: requiredPassword)
        let operation2 = BruteForceOperation(startString: "eeee", endString: "tttt", password: requiredPassword)
        let operation3 = BruteForceOperation(startString: "uuuu", endString: "JJJJ", password: requiredPassword)
        let operation4 = BruteForceOperation(startString: "KKKK", endString: "ZZZZ", password: requiredPassword)
        
        let operationArray = [operation1, operation2, operation3, operation4]
        
        operationQueue.addOperations(operationArray, waitUntilFinished: false)
        
        for op in operationArray {
            op.completionBlock = {
                if let result = op.result {
                    operationQueue.cancelAllOperations()
                    OperationQueue.main.addOperation {
                        self.stop(password: result , startTime: startTime)
                        self.indicator.isHidden = true
                    }
                    
                } else if op.isFinished == false {
                    OperationQueue.main.addOperation {
                        self.stop(password: "Error" , startTime: startTime)
                        self.indicator.isHidden = true
                    }
                }
            }
        }
    }
    
    private func start() {
        bruteForceOperation(password: password)

//        let startTime = Date()
//        let workQueue = DispatchQueue.global(qos: .userInitiated)
//
//        workQueue.async {
//            guard let result = self.bruteForce(startString: "0000", endString: "ZZZZ") else {
//                DispatchQueue.main.async {
//                    self.stop(password: "Error" , startTime: startTime)
//                    self.indicator.isHidden = true
//            }
//                return }
//
//                DispatchQueue.main.async {
//                    self.stop(password: result , startTime: startTime)
//                    self.indicator.isHidden = true
//            }
//        }
    }
    
    // Возвращает подобранный пароль
    private func bruteForce(startString: String, endString: String) -> String? {
        let inputPassword = password
        var startIndexArray = [Int]()
        var endIndexArray = [Int]()
        let maxIndexArray = characterArray.count
        
        // Создает массивы индексов из входных строк
        for char in startString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                startIndexArray.append(index)
            }
        }
        for char in endString {
            for (index, value) in characterArray.enumerated() where value == "\(char)" {
                endIndexArray.append(index)
            }
        }
        
        var currentIndexArray = startIndexArray
        
        // Цикл подбора пароля
        while true {
            
            // Формируем строку проверки пароля из элементов массива символов
            let currentPass = self.characterArray[currentIndexArray[0]] + self.characterArray[currentIndexArray[1]] + self.characterArray[currentIndexArray[2]] + self.characterArray[currentIndexArray[3]]
            
            // Выходим из цикла если пароль найден, или, если дошли до конца массива индексов
            if inputPassword == currentPass {
                return currentPass
            } else {
                if currentIndexArray.elementsEqual(endIndexArray) {
                    break
                }
                
                // Если пароль не найден, то происходит увеличение индекса. Для этого в цикле, начиная с последнего элемента осуществляется проверка текущего значения. Если оно меньше максимального значения (61), то индекс просто увеличивается на 1.
                //Например было [0, 0, 0, 5] а станет [0, 0, 0, 6]. Если же мы уже проверили последний индекс, например [0, 0, 0, 61], то нужно сбросить его в 0, а "старший" индекс увеличить на 1. При этом далее в цикле проверяется переполение "старшего" индекса тем же алгоритмом.
                //Таким образом [0, 0, 0, 61] станет [0, 0, 1, 0]. И поиск продолжится дальше:  [0, 0, 1, 1],  [0, 0, 1, 2],  [0, 0, 1, 3] и т.д.
                for index in (0 ..< currentIndexArray.count).reversed() {
                    guard currentIndexArray[index] < maxIndexArray - 1 else {
                        currentIndexArray[index] = 0
                        continue
                    }
                    currentIndexArray[index] += 1
                    break
                }
            }
        }
        return nil
    }
    
    //Обновляем UI
    private func stop(password: String, startTime: Date) {
        
        indicator.stopAnimating()
        enableStartButton()
        generatePasswordButton.isEnabled = true
        generatePasswordButton.alpha = 1
        passwordLabel.text = "Password is: \(password)"
        statusLabel.text = "Status: Complete"
        bruteForcedTimeLabel.text = "\(String(format: "Time: %.2f", Date().timeIntervalSince(startTime))) seconds"
        
    }
    
    private func clearText() {
        statusLabel.text = "Status:"
        bruteForcedTimeLabel.text = "Time:"
        passwordLabel.text = "Password is:"
    }
    
    private func disableStartButton() {
        startButton.isEnabled = false
        startButton.alpha = 0.5
    }
    
    private func enableStartButton() {
        startButton.isEnabled = true
        startButton.alpha = 1
    }
}

// Добавляем делегат для управления вводом текста в UITextField
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let charCount = inputTextField.text?.count else {
            return
        }
        if charCount != maxTextLength {
            Alert.showBasic(title: "Incorrect password", message: "Password must be 4 characters long", vc: self)
        }
        if charCount > 3 {
            enableStartButton()
        } else {
            disableStartButton()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearText()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let acceptableCharacters = Consts.joinedString
        let characterSet = CharacterSet(charactersIn: acceptableCharacters).inverted
        let newString = NSString(string: text).replacingCharacters(in: range, with: string)
        let filtered = newString.rangeOfCharacter(from: characterSet) == nil
        return newString.count <= maxTextLength && filtered
    }
    
}
