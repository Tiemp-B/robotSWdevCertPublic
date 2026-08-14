import { QuartzTransformerPlugin } from "../types"

// **볼드(괄호)**뒤 처럼 닫는 ** 바로 뒤에 공백/문장부호 없이 글자가 오면
// CommonMark 스펙상 right-flanking 조건을 못 만족해 볼드로 파싱되지 않는 경우가 있음.
// 이를 피하기 위해 **text** 를 <strong>text</strong> 로 직접 치환.
export const BoldFix: QuartzTransformerPlugin = () => ({
  name: "BoldFix",
  textTransform(_ctx, src) {
    return src.replace(/\*\*([^*\n]+?)\*\*/g, "<strong>$1</strong>")
  },
})
