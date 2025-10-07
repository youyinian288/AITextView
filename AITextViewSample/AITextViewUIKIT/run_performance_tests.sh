#!/bin/bash

# AITextView 性能测试运行脚本
# 使用方法: ./run_performance_tests.sh

echo "🚀 开始运行 AITextView 性能测试..."

# 检查是否在正确的目录
if [ ! -f "AITextViewUIKIT.xcodeproj/project.pbxproj" ]; then
    echo "❌ 错误: 请在包含 AITextViewUIKIT.xcodeproj 的目录中运行此脚本"
    exit 1
fi

# 设置测试目标
SCHEME="AITextViewUIKIT"
DESTINATION="platform=iOS Simulator,name=iPhone 15"

echo "📱 使用模拟器: iPhone 15"
echo "🎯 测试方案: $SCHEME"
echo ""

# 运行所有测试
echo "🧪 运行所有测试..."
xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -quiet

if [ $? -eq 0 ]; then
    echo "✅ 所有测试通过!"
else
    echo "❌ 测试失败!"
    exit 1
fi

echo ""
echo "🎉 性能测试完成!"
echo ""
echo "📊 查看详细结果:"
echo "1. 在 Xcode 中打开 Test Navigator (⌘ + 6)"
echo "2. 查看 AITextViewQuickPerformanceTests 的结果"
echo "3. 检查控制台输出的性能报告"
echo ""
echo "💡 提示: 在真机上运行可以获得更准确的性能数据"
