//
// PrivateExplainViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class PrivateExplainViewController: UIViewController {
    var isShowBtn = false
    
    @IBOutlet weak var agreeAndContinueBtn: UIButton!
    @IBOutlet weak var showTextView: UITextView!
    
    @IBOutlet weak var textViewConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var agreeButtonBottomConstraint: NSLayoutConstraint!
    
    private let normalFont = font14 //  UIFont.systemFont(ofSize: 14)
    private let boldFont = fontWithBlod14 // UIFont.boldSystemFont(ofSize: 14)
    
    private let normalColor = UIColor.colorWithSystem(lightColor: UIColor.init(hexString: "#474747"), darkColor: UIColor.init(hexString: "#CCCCCC")) //UIColor.colorWith474747()  // colorWithHexString(hex: "#474747", alpha: 1.0)
    private let boldColor = UIColor.colorWithSystem(lightColor: UIColor.init(hexString: "#151515"), darkColor: UIColor.init(hexString: "#f0f0f0")) // colorWithHexString(hex: "#151515", alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = tr("隐私声明")
        self.agreeAndContinueBtn.isHidden = !self.isShowBtn
        
        self.agreeAndContinueBtn.setTitle(tr("同意并继续"), for: .normal)
        if self.agreeAndContinueBtn.isHidden {
            agreeButtonBottomConstraint.constant = -60
        } else {
            agreeButtonBottomConstraint.constant = 16
        }
        
        
        // 设置导航栏
        if !isShowBtn {
            let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
            self.navigationItem.leftBarButtonItem = leftBarBtnItem
        } else {
            ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isCNlanguage() ? self.showCNText() : self.showENText()
        
    }
    
    func showCNText() {
        showTextView.appendAttributString(string: """
            HW CloudLink是由软通动力信息技术（集团）股份有限公司提供的旨在满足客户随时随地通过视频沟通的需求，为用户提供实时、高效、稳定、安全可靠、高清视音频体验、便捷的数据共享的视讯软件（以下称“本应用”）。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

        请您知悉，本应用仅供企业等非个人组织使用，由您所在的组织或授权您使用本应用的其他组织（以下称“您的组织”）向您提供，有关您的信息的收集和使用等，均由您的组织或依照您的组织的授权或指示进行。您的组织将控制和管理您的会议服务用户账户，包括控制隐私相关设置以及尽到个人数据隐私通知的义务。对于本通知所述个人信息，我们仅是个人信息的处理者，您的组织是个人信息的控制者。
        """, color: boldColor, font: boldFont)
        
        showTextView.appendAttributString(string: """

        本“隐私声明”是为了帮助您了解使用HW CloudLink的过程中，可能涉及的个人信息，以及HW CloudLink如何保护您的个人信息。本通知仅涵盖您的组织在您使用本服务过程中如何收集和处理个人信息，不包括在使用本服务范围之外您的组织处理您的个人信息。除了本通知之外，您的组织可能还会适用其他政策或行为规范，约束与您使用本服务相关的行为。
        请注意，是否在您的个人设备上安装或使用本应用完全出于您的自愿，通过下载、安装、使用HW CloudLink，表明您已经充分理解并同意本隐私通知的所有条款。否则，请停止任何下载、安装和使用行为。
        本声明包括以下内容：
        1. 本应用收集和处理哪些信息
        2. 本应用如何使用这些信息
        3. 本应用是否会披露您的个人信息
        4. 本应用如何保护您的个人信息
        5. 本应用如何留存您的个人信息
        6. 如何查看和更新您的个人数据
        7. 关于新版本软件的下载和安装
        8. 本隐私声明的更新
        9. 联系信息
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

        1 本应用收集和处理哪些信息
        1.1 您或您的组织提交的注册信息
        """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

         您或您的组织通过本应用直接提供的信息，例如在您或您的组织添加或修改您的账户时提供的信息，可能包括：帐号，姓名，手机号码，邮箱地址，联系方式等；您与您的组织沟通时提供的信息等。
         """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

        1.2 设备信息
        """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        HW CloudLink收集关于您登录的个人设备的信息，包括音视频设备信息、操作系统和版本、浏览器信息、IP地址、系统盘存储空间大小，计算机标识信息，以检测个人设备是否满足使用要求。
        """, color: normalColor, font: normalFont)
                
         showTextView.appendAttributString(string: """

          1.3 为使用特定服务而主动提交的数据
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        1)      会议具有音视频能力，在使用此功能的过程中，本软件会使用设备本身或者外置的摄像头、麦克风以及扬声器。
        2)      会议具有共享功能，支持桌面共享，您在使用此功能过程中，基于您自己选择的情况下，会截屏获取对应的内容进行共享。
        """, color: normalColor, font: normalFont)
                
         showTextView.appendAttributString(string: """

          1.4 日志信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        当您使用相关服务时，HW CloudLink会收集日志信息，包括设备IP地址（匿名处理）、用户点击行为、事件信息（如错误、崩溃、重启、升级）、音视频质量数据（如音量大小、丢包率）等数据。音视频质量数据不涉及您的通话内容，仅用于分析音视频质量。 如果您不希望由HW CloudLink收集和分析此类信息，可以在“设置”中关闭相应功能。打开该开关能让运维人员更有效的定位问题、为您提供更好的服务。
        """, color: normalColor, font: normalFont)
                
         showTextView.appendAttributString(string: """

          1.5 口令信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

         当您使用相关服务时，HW CloudLink会在本地收集口令信息，包括登录帐号、登录密码、会议密码等数据。
         口令信息会被加密传输到服务器进行鉴权认证。用户授权后，该信息会被加密保存到本地数据库。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          2 本应用如何使用这些信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

         为了给您提供安全、流畅、有效的使用体验，HW CloudLink在实现以下目的所必要的范围内使用收集的信息和数据：
         1) 为您提供客户支持和故障排查服务
         2) 通知您关于服务更新和故障的信息
         3) 验证您的身份
         4) 解决争议
         5) 遵守所适用的法律、法规要求以及相应相关的法律程序
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          3 本应用是否会披露您的个人信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        3.1 为了使您的组织和您能够使用本应用，您的组织会将以上信息披露给本应用提供者，本应用提供者将仅在您的组织的授权和指示下处理您的个人信息。
        3.2 您的组织还会将您的信息提供给其他协助提供全部或部分服务的第三方服务供应商，包括您通过本应用链接的第三方应用、服务或网站的提供方。
        3.3 您的组织还可能在以下情况下披露您的个人信息：
          （1）根据法律法规的有关规定，或者应行政或司法执法及监管机构的要求，向第三方或者行政机关、司法机构、执法机构或监管机构等有权机构披露。
          （2）如您出现违反所适用的法律、法规或相关政策的情况，根据需要向第三方披露；
          （3）为了向您提供或因您使用所要求的产品或服务，根据需要向第三方披露；
          （4）其他您的组织根据法律、法规或网站政策认为合适的披露，例如处于执行服务条款或为了组织人身、财产损失或非法行为的目的。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          4 本应用如何保护您的个人信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        4.1 本应用提供者重视客户的数据安全，根据您的组织的指示和授权，本应用提供者将采用适当的物理、管理和技术保障措施来保护客户数据和支持数据（包括您的个人信息）不被未经授权访问、披露、使用、修改、损坏或丢失。例如，使用加密技术确保数据的机密性，使用保护机制防止数据遭到恶意攻击，部署访问控制机制，确保只有经您的组织的授权人员才可访问个人信息，以及举办安全和隐私保护培训课程，加强内部人员对于保护个人信息重要性的认识。本应用提供者会根据本声明的约定保护客户数据，但是请注意任何安全措施都无法做到无懈可击。
        4.2 尽管有前述安全措施，但妥善保管您的账户及密码及其他信息的安全是您的责任和义务，请您妥善保管您的信息，否则因此导致的责任由您全部承担。
        4.3 如果发现您帐号或密码被他人非法使用或有使用异常的情况的，应及时通知您的组织的管理员，并可要求您的组织的管理员采取措施，暂停您账户的登录和使用。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          5 本应用如何留存您的个人信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        HW CloudLink只在必要的时间期限内保留您的信息，用以满足本声明所述的所有目的。我们用于确定存留期的标准包括：
        1) 完成该应用目的需要留存个人信息的时间，包括提供产品和服务，应对可能的用户查询或投诉、问题定位；
        2) 用户是否同意更长的留存期间；
        3) 法律、合同等是否有保留数据的特殊要求等。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          6 如何查看和更新您的个人数据
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        您应确保提交的所有个人数据都准确无误。会议服务会尽力维护个人信息的准确和完整，并及时更新这些信息。当适用的法律要求的情况下，您可能有通过您的组织(1)访问本服务提供者持有的关于您的特定的个人信息；(2)要求本服务提供者更新或更正您的不准确的个人信息；(3)拒绝或限制本服务提供者使用您的个人信息；以及(4)要求本服务提供者删除您的个人信息等权利。如果您想行使相关的权利，您可以使用本服务中提供的方法来访问、更正或删除您上传到本服务的信息。如果您无法使用服务内提供的方法来执行这些操作，应直接联系您所在的组织，以访问或修改自己的信息。如果本服务提供者有合理依据认为这些请求存在欺骗性、无法实行或损害他人隐私权，本服务提供者则会拒绝处理请求。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          7 关于新版本软件的下载和安装
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        软件更新版本时，系统提供下载更新提醒。用户授权后，软件将正常安装更新。移动端安装场景下， 软件在下载后用户选择安装，完成更新。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          8 本隐私通知的更新
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        HW CloudLink可能会不定期修改、更新隐私声明，届时我们会提供显著的通知，尽可能通过可行的渠道和方法，将更新通知您。当您升级版本后，我们鼓励您访问隐私声明来了解最新的变化。
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          9 联系信息
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        如果您有任何关于本声明的疑问，请联系您的组织。
        """, color: normalColor, font: normalFont)
    }
    
    func showENText() {
        showTextView.appendAttributString(string: """
            HW CloudLink (hereinafter referred to as the Application) is a video conferencing software provided by iSoftStone Information Technology (Group) Co.,Ltd to enable users to communicate anytime and anywhere. It provides users with efficient, stable, and reliable, HD audiovisual experience, and convenient data sharing.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

        This Application is provided only for non-individual organizations, such as enterprises. It is provided by your organization or other organizations (hereinafter referred to as "your organization") that authorize you to use this Application. Information collection and use shall be performed by your organization or in accordance with your organization's authorization or instructions. Your organization will control and manage your meeting service user accounts, including controlling privacy settings and fulfilling the obligations of personal data privacy notification. We are only the processor of the personal information described in this Statement, and your organization is the controller of such personal information.
        """, color: boldColor, font: boldFont)
        
        showTextView.appendAttributString(string: """

        This Privacy Statement (hereinafter referred to as the Statement) helps you understand personal information that may be involved in using HW CloudLink and how HW CloudLink protects your personal information. This Statement covers only how your organization collects and processes personal information while you are using this Application. It does not cover your organization's handling, if any, of your personal information outside the scope of this Application. In addition to this Statement, your organization may also apply other policies or behavioral norms regarding your use of this Application.
        Please note that it is entirely at your discretion whether to install and use this Application on your personal device. You show your thorough understanding of and consent to all the clauses in this Privacy Statement by downloading, installing, or using HW CloudLink. Otherwise, do not download, install, or use HW CloudLink.
        This Statement sets out:
        1. What Information Is Collected and Processed by this Application
        2. How This Application Uses the Collected Information
        3. Whether This Application Discloses Your Personal Information
        4. How This Application Protects Your Personal Information
        5. How This Application Preserves Your Personal Information
        6. How to View and Update Your Personal Data
        7. How to Download and Install a New Version
        8. Updates to This Statement
        9. Contact Information
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

        1. What Information Is Collected and Processed by this Application
        1.1 Registration Information Submitted by You or Your Organization
        """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

         Information provided by you or your organization through this Application, for example, information provided when you or your organization adds or modifies your account. The information may include the account, name, mobile phone number, email address, and other contact information; and information provided when you communicate with your organization.
         """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

        1.2 Device Information
        """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        This Application collects information about your personal device that you log in to, including audiovisual device information, operating system and version, browser information, IP address, system disk storage space, and computer identification information to check whether your personal device meets the usage requirements.
        """, color: normalColor, font: normalFont)
                
         showTextView.appendAttributString(string: """

          1.3 Data That Is Proactively Submitted for Specific Services
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        (1) This Application features audiovisual functions. When you use these functions, this Application uses your device or external cameras, microphones, and speakers.
        (2) This Application supports desktop sharing in meetings. During desktop sharing, this Application captures your screen to obtain the corresponding content for sharing based on your selection.
        """, color: normalColor, font: normalFont)
                
         showTextView.appendAttributString(string: """

          1.4 Log Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        When you use related services, this Application will collect log information, including the device IP address (after being anonymized), user click-through behaviors, event information (such as error, crash, restart, and upgrade), and audiovisual quality data (such as the volume and packet loss rate). Audiovisual quality data does not involve your call content and is used only for analyzing audiovisual quality. If you do not want this Application to collect and analyze such information, you can disable the corresponding function in Settings. Enabling this function helps O&M personnel locate problems more efficiently and serve you better.
        """, color: normalColor, font: normalFont)
                
         showTextView.appendAttributString(string: """

          1.5 Password Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

         While you are using related services, this Application collects password information locally, including the login account, login password, and meeting password.
         Password information is encrypted and transmitted to the server for authentication. After user authentication, such information is encrypted and saved to the local database.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          2 How This Application Uses the Collected Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

         To provide secure, smooth, and effective user experience, this Application uses the collected information or data as necessary to:
         (1) Provide you with customer support and troubleshooting services.
         (2) Notify you of service updates and faults.
         (3) Verify your identity.
         (4) Resolve disputes.
         (5) Comply with applicable laws, regulations, and corresponding legal procedures.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          3 Whether This Application Discloses Your Personal Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        3.1 To enable your organization and you to use this Application, your organization will disclose the preceding information to the Application provider. The Application provider will process your personal information only under the authorization and instructions of your organization.
        3.2 Your organization will also provide your information to third-party service providers that assist in providing all or part of the services, including third-party applications, services, and websites that are connected to this Application.
        3.3 Your organization may disclose your personal information in the following circumstances:
        (1) In accordance with relevant laws and regulations or the requirements of government departments, your information may be disclosed to third parties; executive, judicial, and law enforcement authorities; and regulatory agencies.
        (2) If you violate relevant laws, regulations, or policies, your information shall be disclosed to third parties.
        (3) To provide you with products or services proactively or as you require, your information shall be disclosed to third parties.
        (4) Other disclosures are deemed appropriate by your organization based on laws, regulations, or website policies, for example, in terms of execution of service clauses or for the purpose of addressing personal injury, property loss, or illegal behavior.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          4 How This Application Protects Your Personal Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        4.1 The Application provider attaches importance to customer data security. According to the instructions and authorization of your organization, the Application provider will use appropriate physical, management, and technical measures to prevent customer data and support data (including your personal information) from unauthorized access, disclosure, use, modification, damage, or loss. For example, the Application provider uses cryptographic technologies for data confidentiality, protection mechanisms to prevent malicious attacks, and access control mechanisms to permit only authorized access to your personal information. The Application provider also provides training on security and privacy protection for employees to strengthen their awareness of personal information protection. The Application provider will protect customer data in accordance with this Statement, but please note that any security measures cannot be impeccable.
        4.2 Notwithstanding the aforesaid security measures, it is your responsibility and obligation to take good care of your account and password as well as your other information, and you shall assume all the legal liabilities arising from your failure to keep your information secure.
        4.3 If you find your account or password is used by others without your permission or abnormal use occurs, notify the administrator of your organization immediately and ask them to suspend any unauthorized use of your account or password.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          5 How This Application Preserves Your Personal Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        This Application preserves your personal information only within a necessary time period to fulfill all purposes described in this Statement. The retention period is determined based on the following considerations:
        (1) The time required to retain personal information to provide products and services, handle possible user queries or complaints, and locate problems;
        (2) Whether the user agrees to a longer retention period;
        (3) Whether there are specific requirements for data retention in laws and contracts.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          6 How to View and Update Your Personal Data
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        You should ensure that all personal data submitted is accurate. This Application is dedicated to maintaining the accuracy and completeness of your personal information and keeping the information up-to-date. In accordance with relevant laws and regulations, you can exercise the following rights through your organization: (1) access your specific personal information held by the Application provider; (2) request the Application provider to update or correct your inaccurate personal information; (3) reject or restrict the use of your personal information by the Application provider; (4) request the Application provider to delete your personal information. If you want to exercise these rights, you can use the methods provided in this Application to access, correct, or delete information that you have uploaded. If you cannot use the methods provided by this Application to perform these operations, directly contact your organization to access or modify your information. The Application provider may decline the request if it has reasonable grounds to believe that the request is fraudulent or unfeasible, or may jeopardize the privacy of others.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          7 How to Download and Install a New Version
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        When a new software version is available, the system will remind you to download the new version. After user authorization, the software can be updated normally. For installation on mobile devices, you can choose to install the software after it is downloaded.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          8 Updates to This Statement
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        This Statement may be revised or updated as needed. We will issue prominent notices or adopt practicable channels or methods to communicate all updates or revisions to you. You are encouraged to read this Statement after a version upgrade to learn about the latest changes.
        """, color: normalColor, font: normalFont)
        
        showTextView.appendAttributString(string: """

          9 Contact Information
          """, color: boldColor, font: boldFont)
        showTextView.appendAttributString(string: """

        If you have any questions about this Statement, please contact your organization.
        """, color: normalColor, font: normalFont)
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func agreeAndContinueBtnClick(_ sender: Any) {
        // 更新状态
        UserDefaults.standard.set("1", forKey: DICT_SAVE_IS_AGREE_PRIVATEEXPLAIN)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if isShowBtn {
            let navVC = self.navigationController as? BaseNavigationController
            navVC?.setNaviIsHidden(ishidden: false, isAnimate: true)
        }
    }
    
}
