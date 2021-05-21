//
//  CarouselDetailViewController.swift
//  SwipeViewPager
//
//  Created by jylee-mac on 2021/05/20.
//

import UIKit

class CarouselDetailViewController: UIViewController {

    public var carouselCollectionViewLayout: CarouselDetailViewLayout? {
           get {
            return carouselView.collectionViewLayout as? CarouselDetailViewLayout
           }
           set {
               if newValue != nil {
                   self.carouselView?.collectionViewLayout = newValue!
               }
           }
       }
    
    let items = [CarouselItem(image: UIImage(named: "essential_card_L"), title: "첫번째") ,
                  CarouselItem(image: UIImage(named: "professional_card_L"), title: "두번째"),
                  CarouselItem(image: UIImage(named: "highend_card_L"), title: "세번째"),
                  CarouselItem(image: UIImage(named: "performance_card_L"), title: "네번째")]
    var selectedIndex = 0
    
    var pageSize: CGSize {
            let layout = self.carouselView?.collectionViewLayout as! CarouselDetailViewLayout
            var pageSize = layout.itemSize
            pageSize.width += layout.minimumLineSpacing
            return pageSize
    }
    
    
    @IBOutlet weak var carouselView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //스크롤 안보이도록
        carouselView.showsVerticalScrollIndicator = false
        carouselView.showsHorizontalScrollIndicator = false

        //horizon scroll 기본 세팅값
        if let layout = carouselCollectionViewLayout {
            let itemWidth = 180//view.bounds.width
            let itemHeight = 250//itemWidth * 0.72
            layout.scrollDirection = .horizontal // 고정값
            layout.itemSize =  CGSize(width: itemWidth, height: itemHeight) //아이템크기
        }
    }
}

extension CarouselDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource
{
       
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as? CarouselCell else {
            return UICollectionViewCell()
        }
        guard let itemImage = items[indexPath.row].image else {
            return UICollectionViewCell()
        }
        
        cell.updateUI(itemImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "CarouselAlertViewController") as! CarouselAlertViewController
        
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        vc.item = item
        present(vc, animated: true, completion: nil)

    }
    
}
struct CarouselItem {
    var image : UIImage?
    var title : String
}
//Cell 아이템 클래스
class CarouselCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    func updateUI(_ image: UIImage) {
        imgView.image = image
    }
}

class CarouselDetailViewLayout: UICollectionViewFlowLayout {

        struct LayoutState {
            var size: CGSize
            var direction: UICollectionView.ScrollDirection
            func isEqual(_ otherState: LayoutState) -> Bool {
                return self.size.equalTo(otherState.size) && self.direction == otherState.direction
            }
        }
        var visibleOffset : CGFloat =  110 //아이템간의 곂치는 간격
        var sideItemScale: CGFloat = 0.6
        var sideItemAlpha: CGFloat = 0.6
        var sideItemShift: CGFloat = 0.0
        
        var state = LayoutState(size: CGSize.zero, direction: .horizontal)
        
        
        override func prepare() {
            super.prepare()
            let currentState = LayoutState(size: self.collectionView!.bounds.size, direction: self.scrollDirection)
            
            if !self.state.isEqual(currentState) {
                self.setupCollectionView()
                self.updateLayout()
                self.state = currentState
            }
        }
        
        func setupCollectionView() {
            guard let collectionView = self.collectionView else { return }
            if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
                collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
            }
        }
        
        func updateLayout() {
            guard let collectionView = self.collectionView else { return }
            
            let collectionSize = collectionView.bounds.size
            let isHorizontal = (self.scrollDirection == .horizontal)
            
            let yInset = (collectionSize.height - self.itemSize.height) / 2
            let xInset = (collectionSize.width - self.itemSize.width) / 2
            self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
            
            let side = isHorizontal ? self.itemSize.width : self.itemSize.height
            let scaledItemOffset =  (side - side * self.sideItemScale) / 2

            let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
            let inset = isHorizontal ? xInset : yInset
            self.minimumLineSpacing = inset - fullSizeSideItemOverlap
          
        }
        
        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            return true
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let superAttributes = super.layoutAttributesForElements(in: rect),
                let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
                else { return nil }
            return attributes.map({ self.transformLayoutAttributes($0) })
        }
        
        func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            guard let collectionView = self.collectionView else { return attributes }
            let isHorizontal = (self.scrollDirection == .horizontal)
            
            let collectionCenter = isHorizontal ? collectionView.frame.size.width/2 : collectionView.frame.size.height/2
            let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
            let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
            
            let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
            let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
            let ratio = (maxDistance - distance)/maxDistance
            
            let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
            let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
            let shift = (1 - ratio) * self.sideItemShift
            attributes.alpha = alpha
            attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            attributes.zIndex = Int(alpha * 10)
            
            if isHorizontal {
                attributes.center.y = attributes.center.y + shift
            } else {
                attributes.center.x = attributes.center.x + shift
            }
            
            return attributes
        }
        
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            guard let collectionView = collectionView , !collectionView.isPagingEnabled,
                let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
                else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
            
            let isHorizontal = (self.scrollDirection == .horizontal)
            
            let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
            let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
            
            var targetContentOffset: CGPoint
            if isHorizontal {
                let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
                targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
            }
            else {
                let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
                targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
            }
            
            return targetContentOffset
        }
    }
