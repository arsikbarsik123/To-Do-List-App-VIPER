import UIKit

final class ToDoCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusView = UIImageView()
    
    private let separator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        separatorLine()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - setupUI && configure

extension ToDoCell {
    private func setupUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        preservesSuperviewLayoutMargins = false
        contentView.preservesSuperviewLayoutMargins = false

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

        statusView.contentMode = .scaleAspectFit

        let bottomRow = UIStackView(arrangedSubviews: [noteLabel, UIView(), dateLabel])
        bottomRow.axis = .vertical
        bottomRow.alignment = .leading
        bottomRow.spacing = 6

        let v = UIStackView(arrangedSubviews: [titleLabel, bottomRow])
        v.axis = .vertical
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(v)
        contentView.addSubview(statusView)
        statusView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: -12),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            statusView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusView.widthAnchor.constraint(equalToConstant: 22),
            statusView.heightAnchor.constraint(equalToConstant: 22),
        ])
    }
    
    func configure(title: String,
                   note: String?,
                   date: String,
                   done: Bool) {
        titleLabel.text = title
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
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        contentView.addSubview(separator)
        
        let onePixel = 1.0 / UIScreen.main.scale
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
}
