//
//  ViewController.swift
//  TestCollecton
//
//  Created by roman on 04.05.2020.
//  Copyright © 2020 ROMAN DOBYNDA. All rights reserved.
//

import UIKit

extension UIView {
    func debugLayout(_ color: UIColor = .red) {
        layer.borderColor = color.cgColor
        layer.borderWidth = 1
    }
}

final class CollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: self)

    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        addSubview(label)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 10
        clipsToBounds = true

        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo:
                leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo:
                trailingAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    let colors: [UIColor] = [.blue, .brown, .cyan, .green, .magenta]

    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)
        return lineView
    }()

    var heightConstraint1: NSLayoutConstraint!

    var heightConstraint2: NSLayoutConstraint!

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.sectionInset.left = 10
        flowLayout.sectionInset.right = 10
        return flowLayout
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.debugLayout()
        view.addSubview(collectionView)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        lineView.backgroundColor = .blue

        setupConstraints()
    }

    func setupConstraints() {
        // portreit
        heightConstraint1 = collectionView.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: 0.4)

        // landscape
        heightConstraint2 = collectionView.heightAnchor.constraint(
            equalTo: view.heightAnchor,
            multiplier: 0.4)

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            lineView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 1),
            lineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if UIDevice.current.orientation.isLandscape {
            heightConstraint1.isActive = false
            heightConstraint2.isActive = true
        } else {
            heightConstraint2.isActive = false
            heightConstraint1.isActive = true
        }

        view.layoutIfNeeded()

        let width = collectionView.bounds.width * 0.8
        let height = collectionView.bounds.height
        flowLayout.itemSize = CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.reuseIdentifier,
            for: indexPath) as! CollectionViewCell
        cell.label.text = "\(indexPath)"
        let index = indexPath.row % colors.count
        cell.label.backgroundColor = colors[index]
//        cell.debugLayout(.black)
        return cell
    }

    var lastCellIndex: Int = 0

    var thresholdVeolicy: CGFloat = 0.8

    func currentCellIndex() -> Int {
        let contentOffsetX = collectionView.contentOffset.x
        let itemWidth = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        let boundWidth = collectionView.bounds.width
        let sectionInset = flowLayout.sectionInset
        let paddingSide = (boundWidth - itemWidth) / 2
        var relativeOffsetX = contentOffsetX + paddingSide
        relativeOffsetX -= sectionInset.left / 2 + sectionInset.right / 2
        relativeOffsetX /= itemWidth
        let index = Int(round(relativeOffsetX))
        return index
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("offsetX", scrollView.contentOffset.x)
        print("index", currentCellIndex())
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastCellIndex = currentCellIndex()
    }

//    // Example 1 (center or left positions)
    var currentVelocity: CGPoint = .zero

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        currentVelocity = velocity
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool)
    {
        var newCellIndex = currentCellIndex()

        if newCellIndex == lastCellIndex {
            if currentVelocity.x > thresholdVeolicy {
                let numberOfItems = collectionView(collectionView,
                                                   numberOfItemsInSection: 0)
                newCellIndex = min(newCellIndex + 1, numberOfItems - 1)
            } else if currentVelocity.x < -thresholdVeolicy {
                newCellIndex = max(newCellIndex - 1, 0)
            }
        }

        // required async
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let self = self else { return }
            // variant 1 (only for center position)
//            let path = IndexPath(row: newCellIndex, section: 0)
//            self.collectionView.scrollToItem(at: path,
//                                             at: .centeredHorizontally,
//                                             animated: true)
            // variant 2 (for left or center positions)
            let itemWidth = self.flowLayout.itemSize.width + self.flowLayout.minimumLineSpacing
            let boundWidth = self.collectionView.bounds.width
            let paddingSide = (boundWidth - itemWidth) / 2
            var x = CGFloat(newCellIndex)
            x *= self.flowLayout.itemSize.width + self.flowLayout.minimumLineSpacing
            // default center position, comment for left position
//            x -= paddingSide

            var maxX = self.collectionView.contentSize.width - self.flowLayout.itemSize.width
            maxX -= self.collectionView.bounds.width - self.flowLayout.itemSize.width

            // calculate for less or greater bounds (optional)
            let safeX = max(0, min(x, maxX))

            let offset = CGPoint(x: safeX, y: 0)
            self.collectionView.setContentOffset(offset, animated: true)
        }
    }

//    // Example 2 (center)
//    func scrollViewWillEndDragging(
//        _ scrollView: UIScrollView,
//        withVelocity velocity: CGPoint,
//        targetContentOffset: UnsafeMutablePointer<CGPoint>)
//    {
//        // Stop scroll propagation
//        targetContentOffset.pointee = scrollView.contentOffset
//
//        var newCellIndex = 0
//
//        if abs(velocity.x) > thresholdVeolicy {
//            newCellIndex = lastCellIndex
//
//            if velocity.x > thresholdVeolicy {
//                let numberOfItems = collectionView(collectionView,
//                                                   numberOfItemsInSection: 0)
//                newCellIndex = min(newCellIndex + 1, numberOfItems - 1)
//            } else if velocity.x < -thresholdVeolicy {
//                newCellIndex = max(newCellIndex - 1, 0)
//            }
//        } else {
//            newCellIndex = currentCellIndex()
//        }
//
//        let path = IndexPath(row: newCellIndex, section: 0)
//        collectionView.scrollToItem(at: path,
//                                    at: .centeredHorizontally,
//                                    animated: true)
//    }
}
