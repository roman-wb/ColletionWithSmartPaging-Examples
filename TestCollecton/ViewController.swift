//
//  ViewController.swift
//  TestCollecton
//
//  Created by roman on 04.05.2020.
//  Copyright © 2020 ROMAN DOBYNDA. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(_ resize: CGSize) -> UIImage? {
        let widthRatio = resize.width / size.width
        let heightRatio = resize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio,
                             height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,
                             height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

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

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        addSubview(imageView)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),

//            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ViewController: UIViewController {

    // MARK: - Props

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        lineView.backgroundColor = .blue

        setupConstraints()
    }

    func setupConstraints() {
        // portrait
        heightConstraint1 = collectionView.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: 0.8 * 0.562)

        // landscape
        heightConstraint2 = collectionView.heightAnchor.constraint(
            equalTo: view.heightAnchor,
            multiplier: 0.8 * 0.562)

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            lineView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lineView.widthAnchor.constraint(
                equalToConstant: 1),
            lineView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 10),
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
        let height = collectionView.bounds.height //* 0.8
        flowLayout.itemSize = CGSize(width: width, height: height)
//        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
//        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    // MARK: - Paging

    var lastCellIndex: Int = 0

    var thresholdVeolicy: CGFloat = 0.8

    func currentCellIndex() -> Int {
        // Perfect solution! Max frame cell on current bounds
        flowLayout.layoutAttributesForElements(
            in: collectionView.bounds
        )?.max {
            let bounds = collectionView.bounds
            let width0 = bounds.intersection($0.frame).width
            let width1 = bounds.intersection($1.frame).width
            return width0 < width1
        }?.indexPath.row ?? 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("offsetX", scrollView.contentOffset.x)
        print("index", currentCellIndex())
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastCellIndex = currentCellIndex()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        // Stop scroll propagation
        targetContentOffset.pointee = scrollView.contentOffset

        var cellIndex = currentCellIndex()

        // Swiped
        if velocity.x > thresholdVeolicy {
            let numberOfItems = collectionView(collectionView,
                                               numberOfItemsInSection: 0)
            cellIndex = min(lastCellIndex + 1, numberOfItems - 1)
        } else if velocity.x < -thresholdVeolicy {
            cellIndex = max(lastCellIndex - 1, 0)
        }

        let path = IndexPath(row: cellIndex, section: 0)
        collectionView.scrollToItem(at: path,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
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

        if indexPath.row % 2 == 0 {
            cell.imageView.image = UIImage(named: "right-bunner-1")!
        } else {
            cell.imageView.image = UIImage(named: "right-bunner-2")!
        }

        return cell
    }
}

extension ViewController: UICollectionViewDelegate { }

extension ViewController: UICollectionViewDelegateFlowLayout { }
