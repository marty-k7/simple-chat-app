//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

// Norint naudoti tableView reikia, confirmint du protokolus
//UITableViewDelegate - sakom, kad musu ChatViewcControleris bus musu tableview pasiuntinys.
//tai reiskia, kad kai kazkas ivyks table view (paspaudziama cell ar pascrolinamas zemyn) visus veiksmus tvarkys muus chatviewcontroller
//UITableViewDataSource - kad data kuria pateiksim musu liste (tableview) mums paruos ir paduos ChatViewController
//UITextFieldDelegate - tas pats kaip tableViewDelegate tik su text fieldu
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
 
    
    var messageArray: [Message] = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint! // ??? kad teksto laukelis galetu pasistumdyti
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:

        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        //sukuriam savo tap gesture atpazintoja. target: self -> priskiriamas sitam ViewControlleriui
        //action: kas nutiks, kai patapinsim. Siuo atveju issaukiam funkcija tableViewTapped ir numazinam klava, kad vartotojas galetu geriau matyti visa chata
        //#selector -> pritaikom metodus (tableViewTapped) objektams (target: self) apie kuriuos dar nezinom iki kol appsas neuzsikure
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        //priskiriam musu tapinimo atpazintoja konkreciam view (vaizdui). siuo atveju musu messageTableView
        messageTableView.addGestureRecognizer(tapGesture)
        
        //TODO: Register your MessageCell.xib file here:
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")

        configureTableView()
        retrieveMessages()
        
        //panaikinam tas linijas tableview'
        messageTableView.separatorStyle = .none
    }

    
    //MARK: - TableView DataSource Methods

    //sita funkcija isijungia, kai tableview iesko, ka parodyti liste (tableView)
    //is esmes: Ka rodysim savo liste? 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //sukuriame nauja cell naudodami tableView metoda dequeueReusableCell as! musu sukurta cele
        //indexPath - location identifier kiekvienai cell - nurodo kur bus rodoma
        //praktiskai sakom: kad kiekvienai naujai eilutei duodam musu costum celle
        //kad tai veiktu butina uzregistruoti savo CostumCell.xib faila viewDidLoad metode -> register UI nib
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
      //istatom parametrus i musu costum cell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        //mesagebody yra apibuditnas musu costum cell class'eje
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as  String! {
            // message we sent
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatLime()
        }
        
        return cell
    }
    //p. s. norint sukurti nauja savo orginalia cell cmd+n -> cocoa touch class -> pasirenkam UITableViewCell + xib failas
    
    
    //TODO: Declare numberOfRowsInSection here:
    //kiek eiluciu vienoje section, (gali buti belenkiek section numberOfSections)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    

    
    //TODO: Declare tableViewTapped here:
    //pakurima funkcija kas nutiks, kad patapinsim ant musu tableView
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    //padarom kad eilutes aukstis pasistumdytu automatiskai priklausomai nuo turinio kiekio
    //padarom standartini auksti, jei bus maziau turinio, visada bus standartinis aukstis, kad graziai atrodytu
    //issaukiam sita funkcija viewDidLoad
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    
    //animuotai pakelia klaviatura kartu su textfieldu, kai paspaudziam ant laukelio.
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    //TODO: Declare textFieldDidEndEditing here:
    //animuotai nuleidzia klava, kai baigiam tipint. REIKIA ISKVIESTI
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.endEditing(true) // sito vargu ar reikia is tiesu
        
        //isjungiam textfielda ir siuntimo knapki kol Firebase issaugos zinute duobazej, kad vartotojas neprisiustu daug zinuciu
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //savo FireBase duonbazej sukuriam nauja poskyri "Messages"
        let messagesDB = Database.database().reference().child("Messages")
        
        //pasakom, kad anas bus Dictionary ir bus sudarytas is dvieju parametru: Sender ir MessageBody, kur sender yra dabar prisijunges vartotojas, o MessageBody - i textfielda ivestas tekstas
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text! ]
        
        //issaugom info i firebase ir patikrinam ar nera klaidu
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("message saved!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                
                self.messageTextfield.text = ""
            }
        }
        
        
    
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        //ieskom event type/child added. paimam duomenis (snapshot), kai tik jie issaugomi ir nurodom kokiu formatu (Dictionary<String, String>)
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            //paimam vertes is naujai i duonbaze issaugotos zinutes
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
           //pridedam vertes i musu message array sukurdami nauja Message klases obijekta
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            
            //uzupdaitinam tableView 
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        
        // MARK: ERROR HANDLER do/try/catch
        //kai metodas gali "throw", tai reiskia gali ismesti klaida ir reikia ideti i do/try/catch error handlinimo bloka
       
        do {
            try Auth.auth().signOut()
            
            //nusoka i pirma langa
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("kazkokia klaida")
        }
    }
    


}
