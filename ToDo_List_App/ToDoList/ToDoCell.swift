import UIKit

final class ToDoCell: UITableViewCell {
    var onToggleStatus: (() -> Void)?

    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusView = UIImageView()
    private let separator = UIView()
    private let highlightView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10) // как системный
        v.alpha = 0
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        separatorLine()
        setupHighlightOverlay()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Animation on tap

extension ToDoCell {
    private func setupHighlightOverlay() {
        contentView.addSubview(highlightView)
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highlightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        selectionStyle = .default
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let block = { self.highlightView.alpha = highlighted ? 1 : 0 }
        animated ? UIView.animate(withDuration: 0.18, animations: block) : block()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let block = { self.highlightView.alpha = selected ? 1 : 0 }
        animated ? UIView.animate(withDuration: 0.18, animations: block) : block()
    }
}

// MARK: - setupUI && configure

extension ToDoCell {
    func setupUI() {
        let sel = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleTap))
        let bottomRow = UIStackView(arrangedSubviews: [noteLabel, UIView(), dateLabel])
        let v = UIStackView(arrangedSubviews: [titleLabel, bottomRow])

        backgroundColor = .black
        contentView.backgroundColor = .black
        preservesSuperviewLayoutMargins = false
        contentView.preservesSuperviewLayoutMargins = false

        sel.backgroundColor = UIColor(white: 1, alpha: 0.08)
        selectedBackgroundView = sel
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusView.contentMode = .scaleAspectFit
        statusView.isUserInteractionEnabled = true
        statusView.addGestureRecognizer(tap)

        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1

        noteLabel.font = .systemFont(ofSize: 15)
        noteLabel.textColor = .systemGray
        noteLabel.numberOfLines = 1
        noteLabel.lineBreakMode = .byTruncatingTail
        noteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .systemGray2
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)

        bottomRow.axis = .vertical
        bottomRow.alignment = .leading
        bottomRow.spacing = 6

        v.axis = .vertical
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statusView)
        contentView.addSubview(v)

        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusView.widthAnchor.constraint(equalToConstant: 22),
            statusView.heightAnchor.constraint(equalToConstant: 22),
            
            v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: 12),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func toggleTap() { onToggleStatus?() }
    
    func configure(title: String,
                   note: String?,
                   date: String,
                   done: Bool) {
        titleLabel.attributedText = applyStrike(title, done: done)
        noteLabel.text  = (note?.isEmpty == false) ? note : ""
        dateLabel.text  = date

        if done {
            statusView.image = UIImage(systemName: "checkmark.circle.fill")
            statusView.tintColor = .systemYellow
        } else {
            statusView.image = UIImage(systemName: "circle")
            statusView.tintColor = .systemGray3
        }
    }
}

// MARK: - separatorLine

extension ToDoCell {
    func separatorLine() {
        let onePixel = 1.0 / UIScreen.main.scale
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: onePixel),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: titleLabel.superview!.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        separator.isHidden = hidden
    }
    
    func applyStrike(_ text: String, done: Bool) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: text)

        if done {
            attr.addAttributes([
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.systemGray
            ], range: NSRange(location: 0, length: attr.length))
        } else {
            attr.removeAttribute(.strikethroughStyle, range: NSRange(location: 0, length: attr.length))
            attr.addAttributes([.foregroundColor: UIColor.white], range: NSRange(location: 0, length: attr.length))
        }
        return attr
    }

}
