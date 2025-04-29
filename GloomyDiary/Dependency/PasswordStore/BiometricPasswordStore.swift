//
//  BiometricPasswordStore.swift
//  GloomyDiary
//
//  Created by 디해 on 4/29/25.
//

import LocalAuthentication
import Security

final class BiometricPasswordStore: PasswordStorable {
    private let account: String = "localPassword"
    
    func save(password: String) {
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .userPresence,
            nil
        ),
              let data = password.data(using: .utf8) else { return }
        
        let context = LAContext()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: access,
            kSecUseAuthenticationContext as String: context
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let context = LAContext()
            context.localizedReason = "비밀번호 해제를 위해 Face ID 인증을 진행합니다."
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true,
                kSecUseAuthenticationContext as String: context
            ]
            
            DispatchQueue.global().async {
                var item: CFTypeRef?
                let status = SecItemCopyMatching(query as CFDictionary, &item)
                
                if status == errSecSuccess,
                   let data = item as? Data,
                   let password = String(data: data, encoding: .utf8) {
                    continuation.resume(returning: password)
                } else {
                    continuation.resume(throwing: CancellationError())
                }
            }
        }
    }
}
