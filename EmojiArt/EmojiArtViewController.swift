//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Alexander Ehrlich on 30.04.21.
//

import UIKit

class EmojiArtViewController: UIViewController{

//MARK: IBOutlets
    
    //view which registers the drop interaction
    @IBOutlet weak var dropZone: UIView!{
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    //Setting up the ScrollView in didSet
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView?.maximumZoomScale = 5.0
            scrollView?.minimumZoomScale = 0.1
            scrollView?.delegate = self
            scrollView?.addSubview(emojiArtView)
        }
    }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet{
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    //Constriants
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    var imageFetcher: ImageFetcher!
    
    var emojis = "🌿☘️🍄🐕‍🦺🐈🦤🦐🐠🐨🐼🩱⚽️".map{String($0)}
    
    //set its background image after drop
    var emojiArtView = EmojiArtView()
    
    //Computed Property for the image
    var emojiArtBackgroundImage: UIImage? {
        
        get{
            return emojiArtView.backgroundImage
        }
        
        set{
            scrollView.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame.size = size
            scrollViewWidthConstraint?.constant = size.height
            scrollViewHeightConstraint?.constant = size.height
            //Das Image sollte immer den gleichen contentSize haben
            scrollView.contentSize = size
            
            if let dropZone = self.dropZone, size.width > 0, size.height > 0{
                scrollView.zoomScale = max(dropZone.bounds.size.width/size.width, dropZone.bounds.size.height/size.height)
            }
        }
    }
    
    
    //MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        emojiCollectionView.register(UINib(nibName: "EmojiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "emojiCell")
    }
}



    //MARK: Collection View Delegate and DataSource
    extension EmojiArtViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            emojis.count
        }
        
        
        private var font: UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64))
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            
            if let emojiCell = cell as? EmojiCollectionViewCell{
                let text = NSAttributedString(string: emojis[indexPath.row], attributes: [.font : font])
                emojiCell.label.attributedText = text
            }
        
            return cell
        }
    }
    
    //MARK: UIScrollView
    extension EmojiArtViewController: UIScrollViewDelegate{
        //Immer wenn gezoomt wurde,  soll height und width des ScrollViews an die content Size angepassdt werden:
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            scrollViewWidthConstraint.constant = scrollView.contentSize.width
            scrollViewHeightConstraint.constant = scrollView.contentSize.height
        }
        
        //Determine which view should be scrollable
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return emojiArtView
        }
    }
    
    //MARK: DropInteraction
    extension EmojiArtViewController: UIDropInteractionDelegate{
        //Requiremnts for the drop
        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            //only drags with image && url are accepted,e.g. if a NSString is dropped, it wont get accepted
            return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            //return a propsal what should happen with the dropped item
            return UIDropProposal(operation: .copy)
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            
            imageFetcher = ImageFetcher() { (url, image) in
                DispatchQueue.main.async {
                    self.emojiArtBackgroundImage = image
                }
            }
            
            //load the objects for the urls
            session.loadObjects(ofClass: NSURL.self) { (nsurls) in
                
                if let url = nsurls.first as? URL {
                    self.imageFetcher.fetch(url)
                }
            }
            
            //load the objects for the images
            session.loadObjects(ofClass: UIImage.self) { (images) in //Images is of type UIItemProvider
                
                if let image = images.first as? UIImage{
                    self.imageFetcher.backup = image
                }
            }
        }
    }

//MARK: CollectionViewDragDelegate
extension EmojiArtViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        
        //localeContext: Daten die innerhalb einer App an eine Session angehängt werden können.
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem]{
        
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            
            //Da es innerhalb der App ist, dann Muss man den ganzen async Kack nicht machen
            dragItem.localObject = attributedString
            return  [dragItem]
        }
        
        return []
    }
}

//MARK: CollectionViewDropDelegate
extension EmojiArtViewController: UICollectionViewDropDelegate{
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        //Es wird überprüft, ob der collectionView auf dem gedroppt werden soll der ist, von dem das DragItem stammt
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        let dropOperation: UIDropOperation = isSelf ? .move : .copy
        
        //intent: Soll eine neue Cell erstellt werden oder in die eingefügt werden, über der man sich gerde befindet?
        return UICollectionViewDropProposal(operation: dropOperation, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        //der coordinator enthält alle informationen
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            //Der IndexPath des Items aus der Collection über der man sich gerade befidnent. Wenn der nil ist, dann weiß man, dass das item nicht aus dieser collectionView ist - easy
            
            //wenn, dass Ergebnis nicht nil ist, dann komme ich aus dem selben CV und muss das Model updaten und die collectionView updaten
            if let sourceIndexPath = item.sourceIndexPath{
            
                if let attributedString = item.dragItem.localObject as? NSAttributedString{
                    
                    //Wenn mehrere inserts und deletes gemacht werden
                    collectionView.performBatchUpdates {
                        
                        //Das Model muss upgedatet werden
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    }
                    
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }else{
                //Ich komme nicht aus meinem eigenen Collecction view, also können die Drop daten länger zum LAden brauchen
                //Da die Daten eine Weile brauchen können, müssen diese async geholten werden. Was macht man solange (kann ja 10 sekunden dauern) --> Man erzeugt einen Placeholder.
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")) // Die Zelle muss erzeugt werden --> Storyboard
                
                //loadObject holt die Daten auf einer anderen Queue
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { provider, error in
                    //Die Benutzeroberfläche muss dann natürlich auf der MainQueue aktualisiert werden:
                    DispatchQueue.main.async {
                        
                        placeholderContext.commitInsertion { insertionIndexPath in
                            //insertionIndexPath kann anders sein als der DEstination, da die CollectionVie in der Zeit in der die Daten angefragt werden, sich verändern kann.
                            
                            if let attributedString = provider as? NSAttributedString{
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            }else{
                                //Falls keine Daten zurückkommen
                                placeholderContext.deletePlaceholder()
                            }
                        }
                    }
                }
            }
        }
    }
}



