//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Alexander Ehrlich on 30.04.21.
//

import UIKit

class EmojiArtView: UIView, UIDropInteractionDelegate{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deselectAllSubviews)))
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay()} }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //Es soll immer in das Bild reinkopiert werden
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            
            let dropPoint = session.location(in: self)
            
            for attributedString in providers as? [NSAttributedString] ?? []{
                self.addLabel(with: attributedString, centeredAt: dropPoint)
            }
        }
    }
    
    
    private func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint){
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addGestures(to: label)
        self.addSubview(label)
    }
}

//MARK: GesturesForEmojis

extension EmojiArtView{
    
    var selectedSubview: UIView? {
        
        get{
            return subviews.filter { $0.layer.borderWidth > 0 }.first
        }
        
        set{
            
            if newValue!.layer.borderWidth > 0 {
                newValue!.layer.borderWidth = 0
            }else{
                deselectAllSubviews()
                newValue!.layer.borderWidth = 2
            }
        }
    }
    
    func addGestures(to view: UIView){
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectEmoji(with:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(zoomSelectedEmoji(with:))))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(moveEmoji(with:))))
    }
    
    @objc func selectEmoji(with recognizer: UITapGestureRecognizer){
    
        let location = recognizer.location(ofTouch: 0, in: self)
        
        for subview in self.subviews{
            
            if let labelSubview = subview as? UILabel{
                if subview.frame.contains(location){
                    selectedSubview = labelSubview
                }
            }
        }
    }
    
    @objc func zoomSelectedEmoji(with recognizer: UIPanGestureRecognizer){
        
        if let movableSubview = selectedSubview {
            if recognizer.view!.frame.intersects(movableSubview.frame){
                let startingX = movableSubview.center.x
                let startingY = movableSubview.center.y
                
                switch recognizer.state {
                
                case .changed:
                    
                    movableSubview.center = CGPoint(x: startingX + recognizer.translation(in: self).x, y: startingY + recognizer.translation(in: self).y)
                    //Jedes mal zurück setzen
                    recognizer.setTranslation(CGPoint.zero, in: self)
                default:
                    break
                }
            }
        }
    }
    
    @objc func moveEmoji(with recognizer: UIPinchGestureRecognizer){
        
        
        if let movableLabel = selectedSubview as? UILabel {
                switch recognizer.state {
                case .changed:
                    movableLabel.attributedText = movableLabel.attributedText?.withFontScaled(by: recognizer.scale)
                    movableLabel.stretchToFit()
                    recognizer.scale = 1.0
                default:
                    break
                }
        }
    }
    
    @objc private func deselectAllSubviews(){
        subviews.forEach { $0.layer.borderWidth = 0 }
    }
    
    
}

extension CGRect{
    func zoom(by scale: CGFloat) -> CGRect {
        
        let newWidth = width * scale
        let newHeight = height * scale
        
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight) / 2)
    }
}

