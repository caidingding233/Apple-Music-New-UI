#!/usr/bin/env node

/**
 * Apple Music MusicKit JS Developer Token 生成器
 * 
 * 使用方法:
 * 1. 在Apple开发者后台创建MusicKit私钥(.p8文件)
 * 2. 将私钥文件放在此脚本同目录下
 * 3. 修改下方配置信息
 * 4. 运行: node generate_developer_token.js
 */

const fs = require('fs');
const jwt = require('jsonwebtoken');
const path = require('path');

// ========== 配置信息 ==========
// 请替换为你的实际信息
const CONFIG = {
  // 你的Team ID (在Apple开发者账户中可以找到)
  teamId: 'YOUR_TEAM_ID_HERE',
  
  // 你的Key ID (创建MusicKit私钥时生成的)
  keyId: 'YOUR_KEY_ID_HERE',
  
  // 私钥文件名 (放在此脚本同目录下)
  privateKeyFile: 'AuthKey_YOUR_KEY_ID.p8',
  
  // Token有效期 (最长180天)
  expiresIn: '180d'
};

// ========== 生成Token ==========
function generateDeveloperToken() {
  try {
    console.log('🎵 Apple Music Developer Token 生成器');
    console.log('=====================================');
    
    // 检查配置
    if (CONFIG.teamId === 'YOUR_TEAM_ID_HERE' || 
        CONFIG.keyId === 'YOUR_KEY_ID_HERE') {
      console.error('❌ 请先配置你的Team ID和Key ID');
      console.log('\n📝 配置步骤:');
      console.log('1. 访问 https://developer.apple.com/account/');
      console.log('2. 找到你的Team ID');
      console.log('3. 创建MusicKit私钥，获取Key ID');
      console.log('4. 下载.p8私钥文件到此目录');
      console.log('5. 修改此脚本中的配置信息');
      return;
    }
    
    // 读取私钥文件
    const privateKeyPath = path.join(__dirname, CONFIG.privateKeyFile);
    
    if (!fs.existsSync(privateKeyPath)) {
      console.error(`❌ 私钥文件不存在: ${CONFIG.privateKeyFile}`);
      console.log('\n请确保私钥文件在此目录下，文件名格式：AuthKey_[KEY_ID].p8');
      return;
    }
    
    console.log(`📁 读取私钥文件: ${CONFIG.privateKeyFile}`);
    const privateKey = fs.readFileSync(privateKeyPath);
    
    // 生成JWT payload
    const payload = {
      iss: CONFIG.teamId,
      iat: Math.floor(Date.now() / 1000)
    };
    
    // JWT选项
    const options = {
      algorithm: 'ES256',
      keyid: CONFIG.keyId,
      expiresIn: CONFIG.expiresIn
    };
    
    // 生成Token
    console.log('🔐 正在生成Developer Token...');
    const token = jwt.sign(payload, privateKey, options);
    
    // 输出结果
    console.log('\n✅ Developer Token 生成成功！');
    console.log('=====================================');
    console.log('\n🔑 Developer Token:');
    console.log(token);
    console.log('\n📋 Token 信息:');
    console.log(`Team ID: ${CONFIG.teamId}`);
    console.log(`Key ID: ${CONFIG.keyId}`);
    console.log(`有效期: ${CONFIG.expiresIn}`);
    console.log(`生成时间: ${new Date().toLocaleString()}`);
    
    // 保存到文件
    const outputFile = 'developer_token.txt';
    fs.writeFileSync(outputFile, token);
    console.log(`\n💾 Token已保存到: ${outputFile}`);
    
    // 使用说明
    console.log('\n📖 使用说明:');
    console.log('1. 复制上面的Developer Token');
    console.log('2. 打开 assets/musickit/index.html');
    console.log('3. 替换 DEVELOPER_TOKEN 常量的值');
    console.log('4. 重新构建Flutter应用');
    
    console.log('\n🎯 下一步操作:');
    console.log('flutter clean && flutter pub get && flutter build web');
    
  } catch (error) {
    console.error('❌ 生成Token失败:', error.message);
    console.log('\n🔧 故障排除:');
    console.log('1. 确保安装了jsonwebtoken包: npm install jsonwebtoken');
    console.log('2. 检查私钥文件格式是否正确');
    console.log('3. 确认Team ID和Key ID配置正确');
  }
}

// ========== 验证环境 ==========
function checkEnvironment() {
  try {
    require('jsonwebtoken');
    return true;
  } catch (error) {
    console.error('❌ 缺少依赖包: jsonwebtoken');
    console.log('\n📦 请先安装依赖:');
    console.log('npm install jsonwebtoken');
    console.log('\n或者:');
    console.log('yarn add jsonwebtoken');
    return false;
  }
}

// ========== 主函数 ==========
function main() {
  if (!checkEnvironment()) {
    return;
  }
  
  generateDeveloperToken();
}

// 运行
if (require.main === module) {
  main();
}

module.exports = {
  generateDeveloperToken,
  CONFIG
}; 