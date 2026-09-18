// CUDA WebShader 0.1.0. Generated from kernel renderUI.
@group(0) @binding(0) var<storage, read> b_S: array<f32>;
@group(0) @binding(1) var<storage, read> b_Brain: array<f32>;
@group(0) @binding(2) var<storage, read> b_I: array<f32>;
@group(0) @binding(3) var<storage, read_write> b_Pixels: array<u32>;
struct CWParams {
  p_width: i32,
  p_height: i32,
  cw_array_4_0: u32,
  cw_array_4_1: u32,
  cw_array_4_2: u32,
  cw_array_4_3: u32,
  cw_array_4_4: u32,
  cw_array_4_5: u32,
  cw_array_4_6: u32,
  cw_array_4_7: u32,
  cw_array_4_8: u32,
  cw_array_4_9: u32,
  cw_array_4_10: u32,
  cw_array_4_11: u32,
  cw_array_4_12: u32,
  cw_array_4_13: u32,
  cw_array_4_14: u32,
  cw_array_4_15: u32,
  cw_array_4_16: u32,
  cw_array_4_17: u32,
  cw_array_4_18: u32,
  cw_array_4_19: u32,
  cw_array_4_20: u32,
  cw_array_4_21: u32,
  cw_array_4_22: u32,
  cw_array_4_23: u32,
  cw_array_4_24: u32,
  cw_array_4_25: u32,
  cw_array_4_26: u32,
  cw_array_4_27: u32,
  cw_array_4_28: u32,
  cw_array_4_29: u32,
  cw_array_4_30: u32,
  cw_array_4_31: u32,
  cw_array_4_32: u32,
  cw_array_4_33: u32,
  cw_array_4_34: u32,
  cw_array_4_35: u32,
  cw_array_4_36: u32,
  cw_array_4_37: u32,
  cw_array_4_38: u32,
  cw_array_4_39: u32,
  cw_array_4_40: u32,
  cw_array_4_41: u32,
  cw_array_4_42: u32,
  cw_array_4_43: u32,
  cw_array_4_44: u32,
  cw_array_4_45: u32,
  cw_array_4_46: u32,
  cw_array_4_47: u32,
  cw_array_4_48: u32,
  cw_array_4_49: u32,
  cw_array_4_50: u32,
  cw_array_4_51: u32,
  cw_array_4_52: u32,
  cw_array_4_53: u32,
  cw_array_4_54: u32,
  cw_array_4_55: u32,
  cw_array_4_56: u32,
  cw_array_4_57: u32,
  cw_array_4_58: u32,
  cw_array_4_59: u32,
  cw_array_4_60: u32,
  cw_array_4_61: u32,
  cw_array_4_62: u32,
  cw_array_4_63: u32,
  cw_array_4_64: u32,
  cw_array_4_65: u32,
  cw_array_4_66: u32,
  cw_array_4_67: u32,
  cw_array_4_68: u32,
  cw_array_4_69: u32,
  cw_array_4_70: u32,
  cw_array_4_71: u32,
  cw_array_4_72: u32,
  cw_array_4_73: u32,
  cw_array_4_74: u32,
  cw_array_4_75: u32,
  cw_array_4_76: u32,
  cw_array_4_77: u32,
  cw_array_4_78: u32,
  cw_array_4_79: u32,
  cw_array_4_80: u32,
  cw_array_4_81: u32,
  cw_array_4_82: u32,
  cw_array_4_83: u32,
  cw_array_4_84: u32,
  cw_array_4_85: u32,
  cw_array_4_86: u32,
  cw_array_4_87: u32,
  cw_array_4_88: u32,
  cw_array_4_89: u32,
  cw_array_4_90: u32,
  cw_array_4_91: u32,
  cw_array_4_92: u32,
  cw_array_4_93: u32,
  cw_array_4_94: u32,
  cw_array_4_95: u32,
  cw_array_4_96: u32,
  cw_array_4_97: u32,
  cw_array_4_98: u32,
  cw_array_4_99: u32,
  cw_array_4_100: u32,
  cw_array_4_101: u32,
  cw_array_4_102: u32,
  cw_array_4_103: u32,
  cw_array_4_104: u32,
  cw_array_4_105: u32,
  cw_array_4_106: u32,
  cw_array_4_107: u32,
  cw_array_4_108: u32,
  cw_array_4_109: u32,
  cw_array_4_110: u32,
  cw_array_4_111: u32,
  cw_array_4_112: u32,
  cw_array_4_113: u32,
  cw_array_4_114: u32,
  cw_array_4_115: u32,
  cw_array_4_116: u32,
  cw_array_4_117: u32,
  cw_array_4_118: u32,
  cw_array_4_119: u32,
  cw_array_4_120: u32,
  cw_array_4_121: u32,
  cw_array_4_122: u32,
  cw_array_4_123: u32,
  cw_array_4_124: u32,
  cw_array_4_125: u32,
  cw_array_4_126: u32,
  cw_array_4_127: u32,
  cw_array_4_128: u32,
  cw_array_4_129: u32,
  cw_array_4_130: u32,
  cw_array_4_131: u32,
  cw_array_4_132: u32,
  cw_array_4_133: u32,
  cw_array_4_134: u32,
  cw_array_4_135: u32,
  cw_array_4_136: u32,
  cw_array_4_137: u32,
  cw_array_4_138: u32,
  cw_array_4_139: u32,
  cw_array_4_140: u32,
  cw_array_4_141: u32,
  cw_array_4_142: u32,
  cw_array_4_143: u32,
  cw_array_4_144: u32,
  cw_array_4_145: u32,
  cw_array_4_146: u32,
  cw_array_4_147: u32,
  cw_array_4_148: u32,
  cw_array_4_149: u32,
  cw_array_4_150: u32,
  cw_array_4_151: u32,
  cw_array_4_152: u32,
  cw_array_4_153: u32,
  cw_array_4_154: u32,
  cw_array_4_155: u32,
  cw_array_4_156: u32,
  cw_array_4_157: u32,
  cw_array_4_158: u32,
  cw_array_4_159: u32,
  cw_array_4_160: u32,
  cw_array_4_161: u32,
  cw_array_4_162: u32,
  cw_array_4_163: u32,
  cw_array_4_164: u32,
  cw_array_4_165: u32,
  cw_array_4_166: u32,
  cw_array_4_167: u32,
  cw_array_4_168: u32,
  cw_array_4_169: u32,
  cw_array_4_170: u32,
  cw_array_4_171: u32,
  cw_array_4_172: u32,
  cw_array_4_173: u32,
  cw_array_4_174: u32,
  cw_array_4_175: u32,
  cw_array_4_176: u32,
  cw_array_4_177: u32,
  cw_array_4_178: u32,
  cw_array_4_179: u32,
  cw_array_4_180: u32,
  cw_array_4_181: u32,
  cw_array_4_182: u32,
  cw_array_4_183: u32,
  cw_array_4_184: u32,
  cw_array_4_185: u32,
  cw_array_4_186: u32,
  cw_array_4_187: u32,
  cw_array_4_188: u32,
  cw_array_4_189: u32,
  cw_array_4_190: u32,
  cw_array_4_191: u32,
  cw_array_4_192: u32,
  cw_array_4_193: u32,
  cw_array_4_194: u32,
  cw_array_4_195: u32,
  cw_array_4_196: u32,
  cw_array_4_197: u32,
  cw_array_4_198: u32,
  cw_array_4_199: u32,
  cw_array_4_200: u32,
  cw_array_4_201: u32,
  cw_array_4_202: u32,
  cw_array_4_203: u32,
  cw_array_4_204: u32,
  cw_array_4_205: u32,
  cw_array_4_206: u32,
  cw_array_4_207: u32,
  cw_array_4_208: u32,
  cw_array_4_209: u32,
  cw_array_4_210: u32,
  cw_array_4_211: u32,
  cw_array_4_212: u32,
  cw_array_4_213: u32,
  cw_array_4_214: u32,
  cw_array_4_215: u32,
  cw_array_4_216: u32,
  cw_array_4_217: u32,
  cw_array_4_218: u32,
  cw_array_4_219: u32,
  cw_array_4_220: u32,
  cw_array_4_221: u32,
  cw_array_4_222: u32,
  cw_array_4_223: u32,
  cw_array_4_224: u32,
  cw_array_4_225: u32,
  cw_array_4_226: u32,
  cw_array_4_227: u32,
  cw_array_4_228: u32,
  cw_array_4_229: u32,
  cw_array_4_230: u32,
  cw_array_4_231: u32,
  cw_array_4_232: u32,
  cw_array_4_233: u32,
  cw_array_4_234: u32,
  cw_array_4_235: u32,
  cw_array_4_236: u32,
  cw_array_4_237: u32,
  cw_array_4_238: u32,
  cw_array_4_239: u32,
  cw_array_4_240: u32,
  cw_array_4_241: u32,
  cw_array_4_242: u32,
  cw_array_4_243: u32,
  cw_array_4_244: u32,
  cw_array_4_245: u32,
  cw_array_4_246: u32,
  cw_array_4_247: u32,
  cw_array_4_248: u32,
  cw_array_4_249: u32,
  cw_array_4_250: u32,
  cw_array_4_251: u32,
  cw_array_4_252: u32,
  cw_array_4_253: u32,
  cw_array_4_254: u32,
  cw_array_4_255: u32,
  cw_array_5_0: u32,
  cw_array_5_1: u32,
  cw_array_5_2: u32,
  cw_array_5_3: u32,
  cw_array_5_4: u32,
  cw_array_5_5: u32,
  cw_array_5_6: u32,
  cw_array_5_7: u32,
  cw_array_5_8: u32,
  cw_array_5_9: u32,
  cw_array_5_10: u32,
  cw_array_5_11: u32,
  cw_array_5_12: u32,
  cw_array_5_13: u32,
  cw_array_5_14: u32,
  cw_array_6_0: u32,
  cw_array_6_1: u32,
  cw_array_6_2: u32,
  cw_array_6_3: u32,
  cw_array_6_4: u32,
  cw_array_6_5: u32,
  cw_array_6_6: u32,
  cw_array_6_7: u32,
  cw_array_6_8: u32,
  cw_array_6_9: u32,
  cw_array_6_10: u32,
  cw_array_6_11: u32,
  cw_array_6_12: u32,
  cw_array_6_13: u32,
  cw_array_6_14: u32,
  cw_array_6_15: u32,
  cw_array_6_16: u32,
  cw_array_6_17: u32,
  cw_array_6_18: u32,
  cw_array_6_19: u32,
  cw_array_6_20: u32,
  cw_array_6_21: u32,
  cw_array_6_22: u32,
  cw_array_6_23: u32,
  cw_array_6_24: u32,
  cw_array_6_25: u32,
  cw_array_6_26: u32,
  cw_array_6_27: u32,
  cw_array_6_28: u32,
  cw_array_6_29: u32,
  cw_array_6_30: u32,
  cw_array_6_31: u32,
  cw_array_6_32: u32,
  cw_array_6_33: u32,
  cw_array_6_34: u32,
  cw_array_6_35: u32,
  cw_array_6_36: u32,
  cw_array_6_37: u32,
  cw_array_6_38: u32,
  cw_array_6_39: u32,
  cw_array_6_40: u32,
  cw_array_6_41: u32,
  cw_array_6_42: u32,
  cw_array_6_43: u32,
  cw_array_6_44: u32,
  cw_array_6_45: u32,
  cw_array_6_46: u32,
  cw_array_6_47: u32,
  cw_array_6_48: u32,
  cw_array_6_49: u32,
  cw_array_6_50: u32,
  cw_array_6_51: u32,
  cw_array_6_52: u32,
  cw_array_6_53: u32,
  cw_array_6_54: u32,
  cw_array_6_55: u32,
  cw_array_6_56: u32,
  cw_array_6_57: u32,
  cw_array_6_58: u32,
  cw_array_6_59: u32,
  cw_array_6_60: u32,
  cw_array_6_61: u32,
  cw_array_6_62: u32,
  cw_array_6_63: u32,
  cw_array_6_64: u32,
  cw_array_6_65: u32,
  cw_array_6_66: u32,
  cw_array_6_67: u32,
  cw_array_6_68: u32,
  cw_array_6_69: u32,
  cw_array_6_70: u32,
  cw_array_6_71: u32,
  cw_array_6_72: u32,
  cw_array_6_73: u32,
  cw_array_6_74: u32,
  cw_array_6_75: u32,
  cw_array_6_76: u32,
  cw_array_6_77: u32,
  cw_array_6_78: u32,
  cw_array_6_79: u32,
  cw_array_6_80: u32,
  cw_array_6_81: u32,
  cw_array_6_82: u32,
  cw_array_6_83: u32,
  cw_array_6_84: u32,
  cw_array_6_85: u32,
  cw_array_6_86: u32,
  cw_array_6_87: u32,
  cw_array_6_88: u32,
  cw_array_6_89: u32,
  cw_array_6_90: u32,
  cw_array_6_91: u32,
  cw_array_6_92: u32,
  cw_array_6_93: u32,
  cw_array_6_94: u32,
  cw_array_6_95: u32,
  cw_array_6_96: u32,
  cw_array_6_97: u32,
  cw_array_6_98: u32,
  cw_array_6_99: u32,
  cw_array_6_100: u32,
  cw_array_6_101: u32,
  cw_array_6_102: u32,
  cw_array_6_103: u32,
  cw_array_6_104: u32,
  cw_array_6_105: u32,
  cw_array_6_106: u32,
  cw_array_6_107: u32,
  cw_array_6_108: u32,
  cw_array_6_109: u32,
  cw_array_6_110: u32,
  cw_array_6_111: u32,
  cw_array_6_112: u32,
  cw_array_6_113: u32,
  cw_array_6_114: u32,
  cw_array_6_115: u32,
  cw_array_6_116: u32,
  cw_array_6_117: u32,
  cw_array_6_118: u32,
  cw_array_6_119: u32,
  cw_array_6_120: u32,
  cw_array_6_121: u32,
  cw_array_6_122: u32,
  cw_array_6_123: u32,
  cw_array_6_124: u32,
  cw_array_6_125: u32,
  cw_array_6_126: u32,
  cw_array_6_127: u32,
  cw_array_6_128: u32,
  cw_array_6_129: u32,
  cw_array_6_130: u32,
  cw_array_6_131: u32,
  cw_array_6_132: u32,
  cw_array_6_133: u32,
  cw_array_6_134: u32,
  cw_array_6_135: u32,
  cw_array_6_136: u32,
  cw_array_6_137: u32,
  cw_array_6_138: u32,
  cw_array_6_139: u32,
  cw_array_6_140: u32,
  cw_array_6_141: u32,
  cw_array_6_142: u32,
  cw_array_6_143: u32,
  cw_array_6_144: u32,
  cw_array_6_145: u32,
  cw_array_6_146: u32,
  cw_array_6_147: u32,
  cw_array_6_148: u32,
  cw_array_6_149: u32,
  cw_array_6_150: u32,
  cw_array_6_151: u32,
  cw_array_6_152: u32,
  cw_array_6_153: u32,
  cw_array_6_154: u32,
  cw_array_6_155: u32,
  cw_array_6_156: u32,
  cw_array_6_157: u32,
  cw_array_6_158: u32,
  cw_array_6_159: u32,
  cw_array_6_160: u32,
  cw_array_6_161: u32,
  cw_array_6_162: u32,
  cw_array_6_163: u32,
  cw_array_6_164: u32,
  cw_array_6_165: u32,
  cw_array_6_166: u32,
  cw_array_6_167: u32,
  cw_array_6_168: u32,
  cw_array_6_169: u32,
  cw_array_6_170: u32,
  cw_array_6_171: u32,
  cw_array_6_172: u32,
  cw_array_6_173: u32,
  cw_array_6_174: u32,
  cw_array_6_175: u32,
  cw_array_6_176: u32,
  cw_array_6_177: u32,
  cw_array_6_178: u32,
  cw_array_6_179: u32,
  cw_array_6_180: u32,
  cw_array_6_181: u32,
  cw_array_6_182: u32,
  cw_array_6_183: u32,
  cw_array_6_184: u32,
  cw_array_6_185: u32,
  cw_array_6_186: u32,
  cw_array_6_187: u32,
  cw_array_6_188: u32,
  cw_array_6_189: u32,
  cw_array_6_190: u32,
  cw_array_6_191: u32,
  cw_array_6_192: u32,
  cw_array_6_193: u32,
  cw_array_6_194: u32,
  cw_array_6_195: u32,
  cw_array_6_196: u32,
  cw_array_6_197: u32,
  cw_array_6_198: u32,
  cw_array_6_199: u32,
  cw_array_6_200: u32,
  cw_array_6_201: u32,
  cw_array_6_202: u32,
  cw_array_6_203: u32,
  cw_array_6_204: u32,
  cw_array_6_205: u32,
  cw_array_6_206: u32,
  cw_array_6_207: u32,
  cw_array_6_208: u32,
  cw_array_6_209: u32,
  cw_array_6_210: u32,
  cw_array_6_211: u32,
  cw_array_6_212: u32,
  cw_array_6_213: u32,
  cw_array_6_214: u32,
  cw_array_6_215: u32,
  cw_array_6_216: u32,
  cw_array_6_217: u32,
  cw_array_6_218: u32,
  cw_array_6_219: u32,
  cw_array_6_220: u32,
  cw_array_6_221: u32,
  cw_array_6_222: u32,
  cw_array_6_223: u32,
  cw_array_6_224: u32,
  cw_array_6_225: u32,
  cw_array_6_226: u32,
  cw_array_6_227: u32,
  cw_array_6_228: u32,
  cw_array_6_229: u32,
  cw_array_6_230: u32,
  cw_array_6_231: u32,
  cw_array_6_232: u32,
  cw_array_6_233: u32,
  cw_array_6_234: u32,
  cw_array_6_235: u32,
  cw_array_6_236: u32,
  cw_array_6_237: u32,
  cw_array_6_238: u32,
  cw_array_6_239: u32,
  cw_array_6_240: u32,
  cw_array_6_241: u32,
  cw_array_6_242: u32,
  cw_array_6_243: u32,
  cw_array_6_244: u32,
  cw_array_6_245: u32,
  cw_array_6_246: u32,
  cw_array_6_247: u32,
  cw_array_6_248: u32,
  cw_array_6_249: u32,
  cw_array_6_250: u32,
  cw_array_6_251: u32,
  cw_array_6_252: u32,
  cw_array_6_253: u32,
  cw_array_6_254: u32,
  cw_array_6_255: u32,
  cw_array_7_0: u32,
  cw_array_7_1: u32,
  cw_array_7_2: u32,
  cw_array_7_3: u32,
  cw_array_7_4: u32,
  cw_array_7_5: u32,
  cw_array_7_6: u32,
  cw_array_7_7: u32,
  cw_array_7_8: u32,
  cw_array_7_9: u32,
  cw_array_7_10: u32,
  cw_array_7_11: u32,
  cw_array_7_12: u32,
  cw_array_7_13: u32,
  cw_array_7_14: u32,
  cw_array_7_15: u32,
  cw_array_7_16: u32,
  cw_array_7_17: u32,
  cw_array_7_18: u32,
  cw_array_7_19: u32,
  cw_array_7_20: u32,
  cw_array_7_21: u32,
  cw_array_7_22: u32,
  cw_array_7_23: u32,
  cw_array_7_24: u32,
  cw_array_7_25: u32,
  cw_array_7_26: u32,
  cw_array_7_27: u32,
  cw_array_7_28: u32,
  cw_array_7_29: u32,
  cw_array_7_30: u32,
  cw_array_7_31: u32,
  cw_array_7_32: u32,
  cw_array_7_33: u32,
  cw_array_7_34: u32,
  cw_array_7_35: u32,
  cw_array_7_36: u32,
  cw_array_7_37: u32,
  cw_array_7_38: u32,
  cw_array_7_39: u32,
  cw_array_7_40: u32,
  cw_array_7_41: u32,
  cw_array_7_42: u32,
  cw_array_7_43: u32,
  cw_array_7_44: u32,
  cw_array_7_45: u32,
  cw_array_7_46: u32,
  cw_array_7_47: u32,
  cw_array_7_48: u32,
  cw_array_7_49: u32,
  cw_array_7_50: u32,
  cw_array_7_51: u32,
  cw_array_7_52: u32,
  cw_array_7_53: u32,
  cw_array_7_54: u32,
  cw_array_7_55: u32,
  cw_array_7_56: u32,
  cw_array_7_57: u32,
  cw_array_7_58: u32,
  cw_array_7_59: u32,
  cw_array_7_60: u32,
  cw_array_7_61: u32,
  cw_array_7_62: u32,
  cw_array_7_63: u32,
  cw_array_7_64: u32,
  cw_array_7_65: u32,
  cw_array_7_66: u32,
  cw_array_7_67: u32,
  cw_array_7_68: u32,
  cw_array_7_69: u32,
  cw_array_7_70: u32,
  cw_array_7_71: u32,
  cw_array_7_72: u32,
  cw_array_7_73: u32,
  cw_array_7_74: u32,
  cw_array_7_75: u32,
  cw_array_7_76: u32,
  cw_array_7_77: u32,
  cw_array_7_78: u32,
  cw_array_7_79: u32,
  cw_array_7_80: u32,
  cw_array_7_81: u32,
  cw_array_7_82: u32,
  cw_array_7_83: u32,
  cw_array_7_84: u32,
  cw_array_7_85: u32,
  cw_array_7_86: u32,
  cw_array_7_87: u32,
  cw_array_7_88: u32,
  cw_array_7_89: u32,
  cw_array_7_90: u32,
  cw_array_7_91: u32,
  cw_array_7_92: u32,
  cw_array_7_93: u32,
  cw_array_7_94: u32,
  cw_array_7_95: u32,
  cw_array_7_96: u32,
  cw_array_7_97: u32,
  cw_array_7_98: u32,
  cw_array_7_99: u32,
  cw_array_7_100: u32,
  cw_array_7_101: u32,
  cw_array_7_102: u32,
  cw_array_7_103: u32,
  cw_array_7_104: u32,
  cw_array_7_105: u32,
  cw_array_7_106: u32,
  cw_array_7_107: u32,
  cw_array_7_108: u32,
  cw_array_7_109: u32,
  cw_array_7_110: u32,
  cw_array_7_111: u32,
  cw_array_7_112: u32,
  cw_array_7_113: u32,
  cw_array_7_114: u32,
  cw_array_7_115: u32,
  cw_array_7_116: u32,
  cw_array_7_117: u32,
  cw_array_7_118: u32,
  cw_array_7_119: u32,
  cw_array_7_120: u32,
  cw_array_7_121: u32,
  cw_array_7_122: u32,
  cw_array_7_123: u32,
  cw_array_7_124: u32,
  cw_array_7_125: u32,
  cw_array_7_126: u32,
  cw_array_7_127: u32,
  cw_array_7_128: u32,
  cw_array_7_129: u32,
  cw_array_7_130: u32,
  cw_array_7_131: u32,
  cw_array_7_132: u32,
  cw_array_7_133: u32,
  cw_array_7_134: u32,
  cw_array_7_135: u32,
  cw_array_7_136: u32,
  cw_array_7_137: u32,
  cw_array_7_138: u32,
  cw_array_7_139: u32,
  cw_array_7_140: u32,
  cw_array_7_141: u32,
  cw_array_7_142: u32,
  cw_array_7_143: u32,
  cw_array_7_144: u32,
  cw_array_7_145: u32,
  cw_array_7_146: u32,
  cw_array_7_147: u32,
  cw_array_7_148: u32,
  cw_array_7_149: u32,
  cw_array_7_150: u32,
  cw_array_7_151: u32,
  cw_array_7_152: u32,
  cw_array_7_153: u32,
  cw_array_7_154: u32,
  cw_array_7_155: u32,
  cw_array_7_156: u32,
  cw_array_7_157: u32,
  cw_array_7_158: u32,
  cw_array_7_159: u32,
  cw_array_7_160: u32,
  cw_array_7_161: u32,
  cw_array_7_162: u32,
  cw_array_7_163: u32,
  cw_array_7_164: u32,
  cw_array_7_165: u32,
  cw_array_7_166: u32,
  cw_array_7_167: u32,
  cw_array_7_168: u32,
  cw_array_7_169: u32,
  cw_array_7_170: u32,
  cw_array_7_171: u32,
  cw_array_7_172: u32,
  cw_array_7_173: u32,
  cw_array_7_174: u32,
  cw_array_7_175: u32,
  cw_array_7_176: u32,
  cw_array_7_177: u32,
  cw_array_7_178: u32,
  cw_array_7_179: u32,
  cw_array_7_180: u32,
  cw_array_7_181: u32,
  cw_array_7_182: u32,
  cw_array_7_183: u32,
  cw_array_7_184: u32,
  cw_array_7_185: u32,
  cw_array_7_186: u32,
  cw_array_7_187: u32,
  cw_array_7_188: u32,
  cw_array_7_189: u32,
  cw_array_7_190: u32,
  cw_array_7_191: u32,
  cw_array_7_192: u32,
  cw_array_7_193: u32,
  cw_array_7_194: u32,
  cw_array_7_195: u32,
  cw_array_7_196: u32,
  cw_array_7_197: u32,
  cw_array_7_198: u32,
  cw_array_7_199: u32,
  cw_array_7_200: u32,
  cw_array_7_201: u32,
  cw_array_7_202: u32,
  cw_array_7_203: u32,
  cw_array_7_204: u32,
  cw_array_7_205: u32,
  cw_array_7_206: u32,
  cw_array_7_207: u32,
  cw_array_7_208: u32,
  cw_array_7_209: u32,
  cw_array_7_210: u32,
  cw_array_7_211: u32,
  cw_array_7_212: u32,
  cw_array_7_213: u32,
  cw_array_7_214: u32,
  cw_array_7_215: u32,
  cw_array_7_216: u32,
  cw_array_7_217: u32,
  cw_array_7_218: u32,
  cw_array_7_219: u32,
  cw_array_7_220: u32,
  cw_array_7_221: u32,
  cw_array_7_222: u32,
  cw_array_7_223: u32,
  cw_array_7_224: u32,
  cw_array_7_225: u32,
  cw_array_7_226: u32,
  cw_array_7_227: u32,
  cw_array_7_228: u32,
  cw_array_7_229: u32,
  cw_array_7_230: u32,
  cw_array_7_231: u32,
  cw_array_7_232: u32,
  cw_array_7_233: u32,
  cw_array_7_234: u32,
  cw_array_7_235: u32,
  cw_array_7_236: u32,
  cw_array_7_237: u32,
  cw_array_7_238: u32,
  cw_array_7_239: u32,
  cw_array_7_240: u32,
  cw_array_7_241: u32,
  cw_array_7_242: u32,
  cw_array_7_243: u32,
  cw_array_7_244: u32,
  cw_array_7_245: u32,
  cw_array_7_246: u32,
  cw_array_7_247: u32,
  cw_array_7_248: u32,
  cw_array_7_249: u32,
  cw_array_7_250: u32,
  cw_array_7_251: u32,
  cw_array_7_252: u32,
  cw_array_7_253: u32,
  cw_array_7_254: u32,
  cw_array_7_255: u32,
  cw_array_8_0: u32,
  cw_array_8_1: u32,
  cw_array_8_2: u32,
  cw_array_8_3: u32,
  cw_array_8_4: u32,
  cw_array_8_5: u32,
  cw_array_8_6: u32,
  cw_array_8_7: u32,
  cw_array_8_8: u32,
  cw_array_8_9: u32,
  cw_array_8_10: u32,
  cw_array_8_11: u32,
  cw_array_8_12: u32,
  cw_array_8_13: u32,
  cw_array_8_14: u32,
  cw_array_8_15: u32,
  cw_array_8_16: u32,
  cw_array_8_17: u32,
  cw_array_8_18: u32,
  cw_array_8_19: u32,
  cw_array_8_20: u32,
  cw_array_8_21: u32,
  cw_array_8_22: u32,
  cw_array_8_23: u32,
  cw_array_8_24: u32,
  cw_array_8_25: u32,
  cw_array_8_26: u32,
  cw_array_8_27: u32,
  cw_array_8_28: u32,
  cw_array_8_29: u32,
  cw_array_8_30: u32,
  cw_array_8_31: u32,
  cw_array_8_32: u32,
  cw_array_8_33: u32,
  cw_array_8_34: u32,
  cw_array_8_35: u32,
  cw_array_8_36: u32,
  cw_array_8_37: u32,
  cw_array_8_38: u32,
  cw_array_8_39: u32,
  cw_array_8_40: u32,
  cw_array_8_41: u32,
  cw_array_8_42: u32,
  cw_array_8_43: u32,
  cw_array_8_44: u32,
  cw_array_8_45: u32,
  cw_array_8_46: u32,
  cw_array_8_47: u32,
  cw_array_8_48: u32,
  cw_array_8_49: u32,
  cw_array_8_50: u32,
  cw_array_8_51: u32,
  cw_array_8_52: u32,
  cw_array_8_53: u32,
  cw_array_8_54: u32,
  cw_array_8_55: u32,
  cw_array_8_56: u32,
  cw_array_8_57: u32,
  cw_array_8_58: u32,
  cw_array_8_59: u32,
  cw_array_8_60: u32,
  cw_array_8_61: u32,
  cw_array_8_62: u32,
  cw_array_8_63: u32,
  cw_array_8_64: u32,
  cw_array_8_65: u32,
  cw_array_8_66: u32,
  cw_array_8_67: u32,
  cw_array_8_68: u32,
  cw_array_8_69: u32,
  cw_array_8_70: u32,
  cw_array_8_71: u32,
  cw_array_8_72: u32,
  cw_array_8_73: u32,
  cw_array_8_74: u32,
  cw_array_8_75: u32,
  cw_array_8_76: u32,
  cw_array_8_77: u32,
  cw_array_8_78: u32,
  cw_array_8_79: u32,
  cw_array_8_80: u32,
  cw_array_8_81: u32,
  cw_array_8_82: u32,
  cw_array_8_83: u32,
  cw_array_8_84: u32,
  cw_array_8_85: u32,
  cw_array_8_86: u32,
  cw_array_8_87: u32,
  cw_array_8_88: u32,
  cw_array_8_89: u32,
  cw_array_8_90: u32,
  cw_array_8_91: u32,
  cw_array_8_92: u32,
  cw_array_8_93: u32,
  cw_array_8_94: u32,
  cw_array_8_95: u32,
  cw_array_8_96: u32,
  cw_array_8_97: u32,
  cw_array_8_98: u32,
  cw_array_8_99: u32,
  cw_array_8_100: u32,
  cw_array_8_101: u32,
  cw_array_8_102: u32,
  cw_array_8_103: u32,
  cw_array_8_104: u32,
  cw_array_8_105: u32,
  cw_array_8_106: u32,
  cw_array_8_107: u32,
  cw_array_8_108: u32,
  cw_array_8_109: u32,
  cw_array_8_110: u32,
  cw_array_8_111: u32,
  cw_array_8_112: u32,
  cw_array_8_113: u32,
  cw_array_8_114: u32,
  cw_array_8_115: u32,
  cw_array_8_116: u32,
  cw_array_8_117: u32,
  cw_array_8_118: u32,
  cw_array_8_119: u32,
  cw_array_8_120: u32,
  cw_array_8_121: u32,
  cw_array_8_122: u32,
  cw_array_8_123: u32,
  cw_array_8_124: u32,
  cw_array_8_125: u32,
  cw_array_8_126: u32,
  cw_array_8_127: u32,
  cw_array_8_128: u32,
  cw_array_8_129: u32,
  cw_array_8_130: u32,
  cw_array_8_131: u32,
  cw_array_8_132: u32,
  cw_array_8_133: u32,
  cw_array_8_134: u32,
  cw_array_8_135: u32,
  cw_array_8_136: u32,
  cw_array_8_137: u32,
  cw_array_0_0: u32,
  cw_array_0_1: u32,
  cw_array_0_2: u32,
  cw_array_0_3: u32,
  cw_array_0_4: u32,
  cw_array_0_5: u32,
  cw_array_0_6: u32,
  cw_array_0_7: u32,
  cw_array_0_8: u32,
  cw_array_0_9: u32,
  cw_array_0_10: u32,
  cw_array_0_11: u32,
  cw_array_0_12: u32,
  cw_array_0_13: u32,
  cw_array_0_14: u32,
  cw_array_0_15: u32,
  cw_array_0_16: u32,
  cw_array_0_17: u32,
  cw_array_0_18: u32,
  cw_array_0_19: u32,
  cw_array_0_20: u32,
  cw_array_0_21: u32,
  cw_array_0_22: u32,
  cw_array_0_23: u32,
  cw_array_0_24: u32,
  cw_array_0_25: u32,
  cw_array_0_26: u32,
  cw_array_0_27: u32,
  cw_array_0_28: u32,
  cw_array_0_29: u32,
  cw_array_0_30: u32,
  cw_array_0_31: u32,
  cw_array_0_32: u32,
  cw_array_0_33: u32,
  cw_array_0_34: u32,
  cw_array_0_35: u32,
  cw_array_0_36: u32,
  cw_array_0_37: u32,
  cw_array_0_38: u32,
  cw_array_0_39: u32,
  cw_array_0_40: u32,
  cw_array_0_41: u32,
  cw_array_0_42: u32,
  cw_array_0_43: u32,
  cw_array_0_44: u32,
  cw_array_0_45: u32,
  cw_array_0_46: u32,
  cw_array_0_47: u32,
  cw_array_0_48: u32,
  cw_array_0_49: u32,
  cw_array_0_50: u32,
  cw_array_0_51: u32,
  cw_array_0_52: u32,
  cw_array_0_53: u32,
  cw_array_0_54: u32,
  cw_array_0_55: u32,
  cw_array_0_56: u32,
  cw_array_0_57: u32,
  cw_array_0_58: u32,
  cw_array_0_59: u32,
  cw_array_0_60: u32,
  cw_array_0_61: u32,
  cw_array_0_62: u32,
  cw_array_0_63: u32,
  cw_array_1_0: u32,
  cw_array_1_1: u32,
  cw_array_1_2: u32,
  cw_array_1_3: u32,
  cw_array_1_4: u32,
  cw_array_1_5: u32,
  cw_array_1_6: u32,
  cw_array_1_7: u32,
  cw_array_1_8: u32,
  cw_array_1_9: u32,
  cw_array_1_10: u32,
  cw_array_1_11: u32,
  cw_array_1_12: u32,
  cw_array_1_13: u32,
  cw_array_1_14: u32,
  cw_array_1_15: u32,
  cw_array_1_16: u32,
  cw_array_1_17: u32,
  cw_array_1_18: u32,
  cw_array_1_19: u32,
  cw_array_1_20: u32,
  cw_array_1_21: u32,
  cw_array_1_22: u32,
  cw_array_1_23: u32,
  cw_array_1_24: u32,
  cw_array_1_25: u32,
  cw_array_1_26: u32,
  cw_array_1_27: u32,
  cw_array_1_28: u32,
  cw_array_1_29: u32,
  cw_array_1_30: u32,
  cw_array_1_31: u32,
  cw_array_1_32: u32,
  cw_array_1_33: u32,
  cw_array_1_34: u32,
  cw_array_1_35: u32,
  cw_array_1_36: u32,
  cw_array_1_37: u32,
  cw_array_1_38: u32,
  cw_array_1_39: u32,
  cw_array_1_40: u32,
  cw_array_1_41: u32,
  cw_array_1_42: u32,
  cw_array_1_43: u32,
  cw_array_1_44: u32,
  cw_array_1_45: u32,
  cw_array_1_46: u32,
  cw_array_1_47: u32,
  cw_array_1_48: u32,
  cw_array_1_49: u32,
  cw_array_1_50: u32,
  cw_array_1_51: u32,
  cw_array_1_52: u32,
  cw_array_1_53: u32,
  cw_array_1_54: u32,
  cw_array_1_55: u32,
  cw_array_1_56: u32,
  cw_array_1_57: u32,
  cw_array_1_58: u32,
  cw_array_1_59: u32,
  cw_array_1_60: u32,
  cw_array_1_61: u32,
  cw_array_1_62: u32,
  cw_array_1_63: u32,
  cw_array_3_0: u32,
  cw_array_3_1: u32,
  cw_array_3_2: u32,
  cw_array_3_3: u32,
  cw_array_3_4: u32,
  cw_array_3_5: u32,
  cw_array_3_6: u32,
  cw_array_3_7: u32,
  cw_array_3_8: u32,
  cw_array_3_9: u32,
  cw_array_3_10: u32,
  cw_array_3_11: u32,
  cw_array_3_12: u32,
  cw_array_3_13: u32,
  cw_array_3_14: u32,
  cw_array_3_15: u32,
  cw_array_3_16: u32,
  cw_array_3_17: u32,
  cw_array_3_18: u32,
  cw_array_3_19: u32,
  cw_array_3_20: u32,
  cw_array_3_21: u32,
  cw_array_3_22: u32,
  cw_array_3_23: u32,
  cw_array_3_24: u32,
  cw_array_3_25: u32,
  cw_array_3_26: u32,
  cw_array_3_27: u32,
  cw_array_3_28: u32,
  cw_array_3_29: u32,
  cw_array_3_30: u32,
  cw_array_3_31: u32,
  cw_array_3_32: u32,
  cw_array_3_33: u32,
  cw_array_3_34: u32,
  cw_array_3_35: u32,
  cw_array_3_36: u32,
  cw_array_3_37: u32,
  cw_array_3_38: u32,
  cw_array_3_39: u32,
  cw_array_3_40: u32,
  cw_array_3_41: u32,
  cw_array_3_42: u32,
  cw_array_3_43: u32,
  cw_array_3_44: u32,
  cw_array_3_45: u32,
  cw_array_3_46: u32,
  cw_array_3_47: u32,
  cw_array_3_48: u32,
  cw_array_3_49: u32,
  cw_array_3_50: u32,
  cw_array_3_51: u32,
  cw_array_3_52: u32,
  cw_array_3_53: u32,
  cw_array_3_54: u32,
  cw_array_3_55: u32,
  cw_array_3_56: u32,
  cw_array_3_57: u32,
  cw_array_3_58: u32,
  cw_array_3_59: u32,
  cw_array_3_60: u32,
  cw_array_3_61: u32,
  cw_array_3_62: u32,
  cw_array_3_63: u32,
  cw_array_3_64: u32,
  cw_array_2_0: u32,
  cw_array_2_1: u32,
  cw_array_2_2: u32,
  cw_array_2_3: u32,
  cw_array_2_4: u32,
  cw_array_2_5: u32,
  cw_array_2_6: u32,
  cw_array_2_7: u32,
  cw_array_2_8: u32,
  cw_array_2_9: u32,
  cw_array_2_10: u32,
  cw_array_2_11: u32,
  cw_array_2_12: u32,
  cw_array_2_13: u32,
  cw_array_2_14: u32,
  cw_array_2_15: u32,
  cw_array_2_16: u32,
  cw_array_2_17: u32,
  cw_array_2_18: u32,
  cw_array_2_19: u32,
  cw_array_2_20: u32,
  cw_array_2_21: u32,
  cw_array_2_22: u32,
  cw_array_2_23: u32,
  cw_array_2_24: u32,
  cw_array_2_25: u32,
  cw_array_2_26: u32,
  cw_array_2_27: u32,
  cw_array_2_28: u32,
  cw_array_2_29: u32,
  cw_array_2_30: u32,
  cw_array_2_31: u32,
  cw_array_2_32: u32,
  cw_array_2_33: u32,
  cw_array_2_34: u32,
  cw_array_2_35: u32,
  cw_array_2_36: u32,
  cw_array_2_37: u32,
  cw_array_2_38: u32,
  cw_array_2_39: u32,
  cw_array_2_40: u32,
  cw_array_2_41: u32,
  cw_array_2_42: u32,
  cw_array_2_43: u32,
  cw_array_2_44: u32,
  cw_array_2_45: u32,
  cw_array_2_46: u32,
  cw_array_2_47: u32,
  cw_array_2_48: u32,
  cw_array_2_49: u32,
  cw_array_2_50: u32,
  cw_array_2_51: u32,
  cw_array_2_52: u32,
  cw_array_2_53: u32,
  cw_array_2_54: u32,
  cw_array_2_55: u32,
  cw_array_2_56: u32,
  cw_array_2_57: u32,
  cw_array_2_58: u32,
  cw_array_2_59: u32,
  cw_array_2_60: u32,
  cw_array_2_61: u32,
  cw_array_2_62: u32,
  cw_array_2_63: u32,
  cw_array_2_64: u32,
  cw_pad_4724: u32,
  cw_pad_4728: u32,
  cw_pad_4732: u32,
}
@group(0) @binding(4) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(8u, 8u, 1u);

fn cw_divide_f32(a: f32, b: f32) -> f32 { let q = a / b; if ((bitcast<u32>(q) & 0x7f800000u) == 0x7f800000u || (bitcast<u32>(q) & 0x7fffffffu) == 0u || (bitcast<u32>(b) & 0x7f800000u) == 0x7f800000u) { return q; } let residual = fma(-q, b, a); return q + residual / b; }
fn f_sat(cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  return min(1.0f, max(0.0f, v_x));
}
fn f_mixf(cw_arg_a: f32, cw_arg_b: f32, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_a: f32 = cw_arg_a;
  var v_b: f32 = cw_arg_b;
  var v_t: f32 = cw_arg_t;
  return (v_a + ((v_b - v_a) * v_t));
}
fn f_len2(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  return sqrt(((v_x * v_x) + (v_y * v_y)));
}
fn f_frac(cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  return (v_x - floor(v_x));
}
fn f_hashf(cw_arg_n: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_n: f32 = cw_arg_n;
  return f_frac((sin(((v_n * 127.1f) + 311.7f)) * 43758.5453f), cw_thread, cw_block, cw_grid);
}
fn f_h2(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  return f_hashf(((v_x * 13.37f) + (v_y * 71.91f)), cw_thread, cw_block, cw_grid);
}
fn f_smooth01(cw_arg_a: f32, cw_arg_b: f32, cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_a: f32 = cw_arg_a;
  var v_b: f32 = cw_arg_b;
  var v_x: f32 = cw_arg_x;
  var v_t: f32 = f_sat(cw_divide_f32((v_x - v_a), (v_b - v_a)), cw_thread, cw_block, cw_grid);
  return ((v_t * v_t) * (3.0f - (2.0f * v_t)));
}
fn f_noise2(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ix: f32 = floor(v_x);
  var v_iy: f32 = floor(v_y);
  var v_fx: f32 = f_frac(v_x, cw_thread, cw_block, cw_grid);
  var v_fy: f32 = f_frac(v_y, cw_thread, cw_block, cw_grid);
  v_fx = ((v_fx * v_fx) * (3.0f - (2.0f * v_fx)));
  v_fy = ((v_fy * v_fy) * (3.0f - (2.0f * v_fy)));
  return f_mixf(f_mixf(f_h2(v_ix, v_iy, cw_thread, cw_block, cw_grid), f_h2((v_ix + 1.0f), v_iy, cw_thread, cw_block, cw_grid), v_fx, cw_thread, cw_block, cw_grid), f_mixf(f_h2(v_ix, (v_iy + 1.0f), cw_thread, cw_block, cw_grid), f_h2((v_ix + 1.0f), (v_iy + 1.0f), cw_thread, cw_block, cw_grid), v_fx, cw_thread, cw_block, cw_grid), v_fy, cw_thread, cw_block, cw_grid);
}
fn f_boxd(cw_arg_x: f32, cw_arg_y: f32, cw_arg_bx: f32, cw_arg_by: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_bx: f32 = cw_arg_bx;
  var v_by: f32 = cw_arg_by;
  var v_qx: f32 = (abs(v_x) - v_bx);
  var v_qy: f32 = (abs(v_y) - v_by);
  return (f_len2(max(v_qx, 0.0f), max(v_qy, 0.0f), cw_thread, cw_block, cw_grid) + min(max(v_qx, v_qy), 0.0f));
}
fn f_segment(cw_arg_x: f32, cw_arg_y: f32, cw_arg_ax: f32, cw_arg_ay: f32, cw_arg_bx: f32, cw_arg_by: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ax: f32 = cw_arg_ax;
  var v_ay: f32 = cw_arg_ay;
  var v_bx: f32 = cw_arg_bx;
  var v_by: f32 = cw_arg_by;
  var v_vx: f32 = (v_bx - v_ax);
  var v_vy: f32 = (v_by - v_ay);
  var v_t: f32 = f_sat(cw_divide_f32((((v_x - v_ax) * v_vx) + ((v_y - v_ay) * v_vy)), (((v_vx * v_vx) + (v_vy * v_vy)) + 0.0001f)), cw_thread, cw_block, cw_grid);
  return f_len2(((v_x - v_ax) - (v_vx * v_t)), ((v_y - v_ay) - (v_vy * v_t)), cw_thread, cw_block, cw_grid);
}
fn f_obstacle(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_gx: f32 = floor(cw_divide_f32((v_x + 96.0f), 192.0f));
  var v_gy: f32 = floor(cw_divide_f32((v_y + 96.0f), 192.0f));
  var v_cx: f32 = ((v_gx * 192.0f) + ((f_h2(v_gx, v_gy, cw_thread, cw_block, cw_grid) - 0.5f) * 60.0f));
  var v_cy: f32 = ((v_gy * 192.0f) + ((f_h2(v_gy, (v_gx + 31.0f), cw_thread, cw_block, cw_grid) - 0.5f) * 50.0f));
  if (((f_len2(v_cx, v_cy, cw_thread, cw_block, cw_grid) < 235.0f) || (f_h2((v_gx + 82.0f), v_gy, cw_thread, cw_block, cw_grid) < 0.35f))) {
    return 1000.0f;
  }
  return f_boxd((v_x - v_cx), (v_y - v_cy), 18.0f, 11.0f, cw_thread, cw_block, cw_grid);
}
fn f_color(cw_arg_r: f32, cw_arg_g: f32, cw_arg_b: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_r: f32 = cw_arg_r;
  var v_g: f32 = cw_arg_g;
  var v_b: f32 = cw_arg_b;
  return vec4<f32>(v_r, v_g, v_b, 1.0f);
}
fn f_blend(cw_arg_a: vec4<f32>, cw_arg_b: vec4<f32>, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_a: vec4<f32> = cw_arg_a;
  var v_b: vec4<f32> = cw_arg_b;
  var v_t: f32 = cw_arg_t;
  return (v_a + ((v_b - v_a) * vec4<f32>(f_sat(v_t, cw_thread, cw_block, cw_grid))));
}
fn f_ink(cw_arg_d: f32, cw_arg_aa: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_d: f32 = cw_arg_d;
  var v_aa: f32 = cw_arg_aa;
  return f_sat((0.5f - cw_divide_f32(v_d, v_aa)), cw_thread, cw_block, cw_grid);
}
fn f_rgba(cw_arg_c: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> u32 {
  var v_c: vec4<f32> = cw_arg_c;
  var v_r: u32 = u32((f_sat(v_c.x, cw_thread, cw_block, cw_grid) * 255.0f));
  var v_g: u32 = u32((f_sat(v_c.y, cw_thread, cw_block, cw_grid) * 255.0f));
  var v_b: u32 = u32((f_sat(v_c.z, cw_thread, cw_block, cw_grid) * 255.0f));
  return (((v_r | (v_g << u32(8i))) | (v_b << u32(16i))) | 4278190080u);
}
fn f_unrgba(cw_arg_c: u32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: u32 = cw_arg_c;
  return vec4<f32>(cw_divide_f32(f32((v_c & 255u)), 255.0f), cw_divide_f32(f32(((v_c >> u32(8i)) & 255u)), 255.0f), cw_divide_f32(f32(((v_c >> u32(16i)) & 255u)), 255.0f), 1.0f);
}
fn f_textWord(cw_arg_i: i32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> u32 {
  var v_i: i32 = cw_arg_i;
  if ((v_i < 256i)) {
    return array<u32, 256>(cw_params.cw_array_4_0, cw_params.cw_array_4_1, cw_params.cw_array_4_2, cw_params.cw_array_4_3, cw_params.cw_array_4_4, cw_params.cw_array_4_5, cw_params.cw_array_4_6, cw_params.cw_array_4_7, cw_params.cw_array_4_8, cw_params.cw_array_4_9, cw_params.cw_array_4_10, cw_params.cw_array_4_11, cw_params.cw_array_4_12, cw_params.cw_array_4_13, cw_params.cw_array_4_14, cw_params.cw_array_4_15, cw_params.cw_array_4_16, cw_params.cw_array_4_17, cw_params.cw_array_4_18, cw_params.cw_array_4_19, cw_params.cw_array_4_20, cw_params.cw_array_4_21, cw_params.cw_array_4_22, cw_params.cw_array_4_23, cw_params.cw_array_4_24, cw_params.cw_array_4_25, cw_params.cw_array_4_26, cw_params.cw_array_4_27, cw_params.cw_array_4_28, cw_params.cw_array_4_29, cw_params.cw_array_4_30, cw_params.cw_array_4_31, cw_params.cw_array_4_32, cw_params.cw_array_4_33, cw_params.cw_array_4_34, cw_params.cw_array_4_35, cw_params.cw_array_4_36, cw_params.cw_array_4_37, cw_params.cw_array_4_38, cw_params.cw_array_4_39, cw_params.cw_array_4_40, cw_params.cw_array_4_41, cw_params.cw_array_4_42, cw_params.cw_array_4_43, cw_params.cw_array_4_44, cw_params.cw_array_4_45, cw_params.cw_array_4_46, cw_params.cw_array_4_47, cw_params.cw_array_4_48, cw_params.cw_array_4_49, cw_params.cw_array_4_50, cw_params.cw_array_4_51, cw_params.cw_array_4_52, cw_params.cw_array_4_53, cw_params.cw_array_4_54, cw_params.cw_array_4_55, cw_params.cw_array_4_56, cw_params.cw_array_4_57, cw_params.cw_array_4_58, cw_params.cw_array_4_59, cw_params.cw_array_4_60, cw_params.cw_array_4_61, cw_params.cw_array_4_62, cw_params.cw_array_4_63, cw_params.cw_array_4_64, cw_params.cw_array_4_65, cw_params.cw_array_4_66, cw_params.cw_array_4_67, cw_params.cw_array_4_68, cw_params.cw_array_4_69, cw_params.cw_array_4_70, cw_params.cw_array_4_71, cw_params.cw_array_4_72, cw_params.cw_array_4_73, cw_params.cw_array_4_74, cw_params.cw_array_4_75, cw_params.cw_array_4_76, cw_params.cw_array_4_77, cw_params.cw_array_4_78, cw_params.cw_array_4_79, cw_params.cw_array_4_80, cw_params.cw_array_4_81, cw_params.cw_array_4_82, cw_params.cw_array_4_83, cw_params.cw_array_4_84, cw_params.cw_array_4_85, cw_params.cw_array_4_86, cw_params.cw_array_4_87, cw_params.cw_array_4_88, cw_params.cw_array_4_89, cw_params.cw_array_4_90, cw_params.cw_array_4_91, cw_params.cw_array_4_92, cw_params.cw_array_4_93, cw_params.cw_array_4_94, cw_params.cw_array_4_95, cw_params.cw_array_4_96, cw_params.cw_array_4_97, cw_params.cw_array_4_98, cw_params.cw_array_4_99, cw_params.cw_array_4_100, cw_params.cw_array_4_101, cw_params.cw_array_4_102, cw_params.cw_array_4_103, cw_params.cw_array_4_104, cw_params.cw_array_4_105, cw_params.cw_array_4_106, cw_params.cw_array_4_107, cw_params.cw_array_4_108, cw_params.cw_array_4_109, cw_params.cw_array_4_110, cw_params.cw_array_4_111, cw_params.cw_array_4_112, cw_params.cw_array_4_113, cw_params.cw_array_4_114, cw_params.cw_array_4_115, cw_params.cw_array_4_116, cw_params.cw_array_4_117, cw_params.cw_array_4_118, cw_params.cw_array_4_119, cw_params.cw_array_4_120, cw_params.cw_array_4_121, cw_params.cw_array_4_122, cw_params.cw_array_4_123, cw_params.cw_array_4_124, cw_params.cw_array_4_125, cw_params.cw_array_4_126, cw_params.cw_array_4_127, cw_params.cw_array_4_128, cw_params.cw_array_4_129, cw_params.cw_array_4_130, cw_params.cw_array_4_131, cw_params.cw_array_4_132, cw_params.cw_array_4_133, cw_params.cw_array_4_134, cw_params.cw_array_4_135, cw_params.cw_array_4_136, cw_params.cw_array_4_137, cw_params.cw_array_4_138, cw_params.cw_array_4_139, cw_params.cw_array_4_140, cw_params.cw_array_4_141, cw_params.cw_array_4_142, cw_params.cw_array_4_143, cw_params.cw_array_4_144, cw_params.cw_array_4_145, cw_params.cw_array_4_146, cw_params.cw_array_4_147, cw_params.cw_array_4_148, cw_params.cw_array_4_149, cw_params.cw_array_4_150, cw_params.cw_array_4_151, cw_params.cw_array_4_152, cw_params.cw_array_4_153, cw_params.cw_array_4_154, cw_params.cw_array_4_155, cw_params.cw_array_4_156, cw_params.cw_array_4_157, cw_params.cw_array_4_158, cw_params.cw_array_4_159, cw_params.cw_array_4_160, cw_params.cw_array_4_161, cw_params.cw_array_4_162, cw_params.cw_array_4_163, cw_params.cw_array_4_164, cw_params.cw_array_4_165, cw_params.cw_array_4_166, cw_params.cw_array_4_167, cw_params.cw_array_4_168, cw_params.cw_array_4_169, cw_params.cw_array_4_170, cw_params.cw_array_4_171, cw_params.cw_array_4_172, cw_params.cw_array_4_173, cw_params.cw_array_4_174, cw_params.cw_array_4_175, cw_params.cw_array_4_176, cw_params.cw_array_4_177, cw_params.cw_array_4_178, cw_params.cw_array_4_179, cw_params.cw_array_4_180, cw_params.cw_array_4_181, cw_params.cw_array_4_182, cw_params.cw_array_4_183, cw_params.cw_array_4_184, cw_params.cw_array_4_185, cw_params.cw_array_4_186, cw_params.cw_array_4_187, cw_params.cw_array_4_188, cw_params.cw_array_4_189, cw_params.cw_array_4_190, cw_params.cw_array_4_191, cw_params.cw_array_4_192, cw_params.cw_array_4_193, cw_params.cw_array_4_194, cw_params.cw_array_4_195, cw_params.cw_array_4_196, cw_params.cw_array_4_197, cw_params.cw_array_4_198, cw_params.cw_array_4_199, cw_params.cw_array_4_200, cw_params.cw_array_4_201, cw_params.cw_array_4_202, cw_params.cw_array_4_203, cw_params.cw_array_4_204, cw_params.cw_array_4_205, cw_params.cw_array_4_206, cw_params.cw_array_4_207, cw_params.cw_array_4_208, cw_params.cw_array_4_209, cw_params.cw_array_4_210, cw_params.cw_array_4_211, cw_params.cw_array_4_212, cw_params.cw_array_4_213, cw_params.cw_array_4_214, cw_params.cw_array_4_215, cw_params.cw_array_4_216, cw_params.cw_array_4_217, cw_params.cw_array_4_218, cw_params.cw_array_4_219, cw_params.cw_array_4_220, cw_params.cw_array_4_221, cw_params.cw_array_4_222, cw_params.cw_array_4_223, cw_params.cw_array_4_224, cw_params.cw_array_4_225, cw_params.cw_array_4_226, cw_params.cw_array_4_227, cw_params.cw_array_4_228, cw_params.cw_array_4_229, cw_params.cw_array_4_230, cw_params.cw_array_4_231, cw_params.cw_array_4_232, cw_params.cw_array_4_233, cw_params.cw_array_4_234, cw_params.cw_array_4_235, cw_params.cw_array_4_236, cw_params.cw_array_4_237, cw_params.cw_array_4_238, cw_params.cw_array_4_239, cw_params.cw_array_4_240, cw_params.cw_array_4_241, cw_params.cw_array_4_242, cw_params.cw_array_4_243, cw_params.cw_array_4_244, cw_params.cw_array_4_245, cw_params.cw_array_4_246, cw_params.cw_array_4_247, cw_params.cw_array_4_248, cw_params.cw_array_4_249, cw_params.cw_array_4_250, cw_params.cw_array_4_251, cw_params.cw_array_4_252, cw_params.cw_array_4_253, cw_params.cw_array_4_254, cw_params.cw_array_4_255)[(v_i - 0i)];
  }
  if ((v_i < 271i)) {
    return array<u32, 15>(cw_params.cw_array_5_0, cw_params.cw_array_5_1, cw_params.cw_array_5_2, cw_params.cw_array_5_3, cw_params.cw_array_5_4, cw_params.cw_array_5_5, cw_params.cw_array_5_6, cw_params.cw_array_5_7, cw_params.cw_array_5_8, cw_params.cw_array_5_9, cw_params.cw_array_5_10, cw_params.cw_array_5_11, cw_params.cw_array_5_12, cw_params.cw_array_5_13, cw_params.cw_array_5_14)[(v_i - 256i)];
  }
  return 0u;
}
fn f_titleWord(cw_arg_i: i32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> u32 {
  var v_i: i32 = cw_arg_i;
  if ((v_i < 256i)) {
    return array<u32, 256>(cw_params.cw_array_6_0, cw_params.cw_array_6_1, cw_params.cw_array_6_2, cw_params.cw_array_6_3, cw_params.cw_array_6_4, cw_params.cw_array_6_5, cw_params.cw_array_6_6, cw_params.cw_array_6_7, cw_params.cw_array_6_8, cw_params.cw_array_6_9, cw_params.cw_array_6_10, cw_params.cw_array_6_11, cw_params.cw_array_6_12, cw_params.cw_array_6_13, cw_params.cw_array_6_14, cw_params.cw_array_6_15, cw_params.cw_array_6_16, cw_params.cw_array_6_17, cw_params.cw_array_6_18, cw_params.cw_array_6_19, cw_params.cw_array_6_20, cw_params.cw_array_6_21, cw_params.cw_array_6_22, cw_params.cw_array_6_23, cw_params.cw_array_6_24, cw_params.cw_array_6_25, cw_params.cw_array_6_26, cw_params.cw_array_6_27, cw_params.cw_array_6_28, cw_params.cw_array_6_29, cw_params.cw_array_6_30, cw_params.cw_array_6_31, cw_params.cw_array_6_32, cw_params.cw_array_6_33, cw_params.cw_array_6_34, cw_params.cw_array_6_35, cw_params.cw_array_6_36, cw_params.cw_array_6_37, cw_params.cw_array_6_38, cw_params.cw_array_6_39, cw_params.cw_array_6_40, cw_params.cw_array_6_41, cw_params.cw_array_6_42, cw_params.cw_array_6_43, cw_params.cw_array_6_44, cw_params.cw_array_6_45, cw_params.cw_array_6_46, cw_params.cw_array_6_47, cw_params.cw_array_6_48, cw_params.cw_array_6_49, cw_params.cw_array_6_50, cw_params.cw_array_6_51, cw_params.cw_array_6_52, cw_params.cw_array_6_53, cw_params.cw_array_6_54, cw_params.cw_array_6_55, cw_params.cw_array_6_56, cw_params.cw_array_6_57, cw_params.cw_array_6_58, cw_params.cw_array_6_59, cw_params.cw_array_6_60, cw_params.cw_array_6_61, cw_params.cw_array_6_62, cw_params.cw_array_6_63, cw_params.cw_array_6_64, cw_params.cw_array_6_65, cw_params.cw_array_6_66, cw_params.cw_array_6_67, cw_params.cw_array_6_68, cw_params.cw_array_6_69, cw_params.cw_array_6_70, cw_params.cw_array_6_71, cw_params.cw_array_6_72, cw_params.cw_array_6_73, cw_params.cw_array_6_74, cw_params.cw_array_6_75, cw_params.cw_array_6_76, cw_params.cw_array_6_77, cw_params.cw_array_6_78, cw_params.cw_array_6_79, cw_params.cw_array_6_80, cw_params.cw_array_6_81, cw_params.cw_array_6_82, cw_params.cw_array_6_83, cw_params.cw_array_6_84, cw_params.cw_array_6_85, cw_params.cw_array_6_86, cw_params.cw_array_6_87, cw_params.cw_array_6_88, cw_params.cw_array_6_89, cw_params.cw_array_6_90, cw_params.cw_array_6_91, cw_params.cw_array_6_92, cw_params.cw_array_6_93, cw_params.cw_array_6_94, cw_params.cw_array_6_95, cw_params.cw_array_6_96, cw_params.cw_array_6_97, cw_params.cw_array_6_98, cw_params.cw_array_6_99, cw_params.cw_array_6_100, cw_params.cw_array_6_101, cw_params.cw_array_6_102, cw_params.cw_array_6_103, cw_params.cw_array_6_104, cw_params.cw_array_6_105, cw_params.cw_array_6_106, cw_params.cw_array_6_107, cw_params.cw_array_6_108, cw_params.cw_array_6_109, cw_params.cw_array_6_110, cw_params.cw_array_6_111, cw_params.cw_array_6_112, cw_params.cw_array_6_113, cw_params.cw_array_6_114, cw_params.cw_array_6_115, cw_params.cw_array_6_116, cw_params.cw_array_6_117, cw_params.cw_array_6_118, cw_params.cw_array_6_119, cw_params.cw_array_6_120, cw_params.cw_array_6_121, cw_params.cw_array_6_122, cw_params.cw_array_6_123, cw_params.cw_array_6_124, cw_params.cw_array_6_125, cw_params.cw_array_6_126, cw_params.cw_array_6_127, cw_params.cw_array_6_128, cw_params.cw_array_6_129, cw_params.cw_array_6_130, cw_params.cw_array_6_131, cw_params.cw_array_6_132, cw_params.cw_array_6_133, cw_params.cw_array_6_134, cw_params.cw_array_6_135, cw_params.cw_array_6_136, cw_params.cw_array_6_137, cw_params.cw_array_6_138, cw_params.cw_array_6_139, cw_params.cw_array_6_140, cw_params.cw_array_6_141, cw_params.cw_array_6_142, cw_params.cw_array_6_143, cw_params.cw_array_6_144, cw_params.cw_array_6_145, cw_params.cw_array_6_146, cw_params.cw_array_6_147, cw_params.cw_array_6_148, cw_params.cw_array_6_149, cw_params.cw_array_6_150, cw_params.cw_array_6_151, cw_params.cw_array_6_152, cw_params.cw_array_6_153, cw_params.cw_array_6_154, cw_params.cw_array_6_155, cw_params.cw_array_6_156, cw_params.cw_array_6_157, cw_params.cw_array_6_158, cw_params.cw_array_6_159, cw_params.cw_array_6_160, cw_params.cw_array_6_161, cw_params.cw_array_6_162, cw_params.cw_array_6_163, cw_params.cw_array_6_164, cw_params.cw_array_6_165, cw_params.cw_array_6_166, cw_params.cw_array_6_167, cw_params.cw_array_6_168, cw_params.cw_array_6_169, cw_params.cw_array_6_170, cw_params.cw_array_6_171, cw_params.cw_array_6_172, cw_params.cw_array_6_173, cw_params.cw_array_6_174, cw_params.cw_array_6_175, cw_params.cw_array_6_176, cw_params.cw_array_6_177, cw_params.cw_array_6_178, cw_params.cw_array_6_179, cw_params.cw_array_6_180, cw_params.cw_array_6_181, cw_params.cw_array_6_182, cw_params.cw_array_6_183, cw_params.cw_array_6_184, cw_params.cw_array_6_185, cw_params.cw_array_6_186, cw_params.cw_array_6_187, cw_params.cw_array_6_188, cw_params.cw_array_6_189, cw_params.cw_array_6_190, cw_params.cw_array_6_191, cw_params.cw_array_6_192, cw_params.cw_array_6_193, cw_params.cw_array_6_194, cw_params.cw_array_6_195, cw_params.cw_array_6_196, cw_params.cw_array_6_197, cw_params.cw_array_6_198, cw_params.cw_array_6_199, cw_params.cw_array_6_200, cw_params.cw_array_6_201, cw_params.cw_array_6_202, cw_params.cw_array_6_203, cw_params.cw_array_6_204, cw_params.cw_array_6_205, cw_params.cw_array_6_206, cw_params.cw_array_6_207, cw_params.cw_array_6_208, cw_params.cw_array_6_209, cw_params.cw_array_6_210, cw_params.cw_array_6_211, cw_params.cw_array_6_212, cw_params.cw_array_6_213, cw_params.cw_array_6_214, cw_params.cw_array_6_215, cw_params.cw_array_6_216, cw_params.cw_array_6_217, cw_params.cw_array_6_218, cw_params.cw_array_6_219, cw_params.cw_array_6_220, cw_params.cw_array_6_221, cw_params.cw_array_6_222, cw_params.cw_array_6_223, cw_params.cw_array_6_224, cw_params.cw_array_6_225, cw_params.cw_array_6_226, cw_params.cw_array_6_227, cw_params.cw_array_6_228, cw_params.cw_array_6_229, cw_params.cw_array_6_230, cw_params.cw_array_6_231, cw_params.cw_array_6_232, cw_params.cw_array_6_233, cw_params.cw_array_6_234, cw_params.cw_array_6_235, cw_params.cw_array_6_236, cw_params.cw_array_6_237, cw_params.cw_array_6_238, cw_params.cw_array_6_239, cw_params.cw_array_6_240, cw_params.cw_array_6_241, cw_params.cw_array_6_242, cw_params.cw_array_6_243, cw_params.cw_array_6_244, cw_params.cw_array_6_245, cw_params.cw_array_6_246, cw_params.cw_array_6_247, cw_params.cw_array_6_248, cw_params.cw_array_6_249, cw_params.cw_array_6_250, cw_params.cw_array_6_251, cw_params.cw_array_6_252, cw_params.cw_array_6_253, cw_params.cw_array_6_254, cw_params.cw_array_6_255)[(v_i - 0i)];
  }
  if ((v_i < 512i)) {
    return array<u32, 256>(cw_params.cw_array_7_0, cw_params.cw_array_7_1, cw_params.cw_array_7_2, cw_params.cw_array_7_3, cw_params.cw_array_7_4, cw_params.cw_array_7_5, cw_params.cw_array_7_6, cw_params.cw_array_7_7, cw_params.cw_array_7_8, cw_params.cw_array_7_9, cw_params.cw_array_7_10, cw_params.cw_array_7_11, cw_params.cw_array_7_12, cw_params.cw_array_7_13, cw_params.cw_array_7_14, cw_params.cw_array_7_15, cw_params.cw_array_7_16, cw_params.cw_array_7_17, cw_params.cw_array_7_18, cw_params.cw_array_7_19, cw_params.cw_array_7_20, cw_params.cw_array_7_21, cw_params.cw_array_7_22, cw_params.cw_array_7_23, cw_params.cw_array_7_24, cw_params.cw_array_7_25, cw_params.cw_array_7_26, cw_params.cw_array_7_27, cw_params.cw_array_7_28, cw_params.cw_array_7_29, cw_params.cw_array_7_30, cw_params.cw_array_7_31, cw_params.cw_array_7_32, cw_params.cw_array_7_33, cw_params.cw_array_7_34, cw_params.cw_array_7_35, cw_params.cw_array_7_36, cw_params.cw_array_7_37, cw_params.cw_array_7_38, cw_params.cw_array_7_39, cw_params.cw_array_7_40, cw_params.cw_array_7_41, cw_params.cw_array_7_42, cw_params.cw_array_7_43, cw_params.cw_array_7_44, cw_params.cw_array_7_45, cw_params.cw_array_7_46, cw_params.cw_array_7_47, cw_params.cw_array_7_48, cw_params.cw_array_7_49, cw_params.cw_array_7_50, cw_params.cw_array_7_51, cw_params.cw_array_7_52, cw_params.cw_array_7_53, cw_params.cw_array_7_54, cw_params.cw_array_7_55, cw_params.cw_array_7_56, cw_params.cw_array_7_57, cw_params.cw_array_7_58, cw_params.cw_array_7_59, cw_params.cw_array_7_60, cw_params.cw_array_7_61, cw_params.cw_array_7_62, cw_params.cw_array_7_63, cw_params.cw_array_7_64, cw_params.cw_array_7_65, cw_params.cw_array_7_66, cw_params.cw_array_7_67, cw_params.cw_array_7_68, cw_params.cw_array_7_69, cw_params.cw_array_7_70, cw_params.cw_array_7_71, cw_params.cw_array_7_72, cw_params.cw_array_7_73, cw_params.cw_array_7_74, cw_params.cw_array_7_75, cw_params.cw_array_7_76, cw_params.cw_array_7_77, cw_params.cw_array_7_78, cw_params.cw_array_7_79, cw_params.cw_array_7_80, cw_params.cw_array_7_81, cw_params.cw_array_7_82, cw_params.cw_array_7_83, cw_params.cw_array_7_84, cw_params.cw_array_7_85, cw_params.cw_array_7_86, cw_params.cw_array_7_87, cw_params.cw_array_7_88, cw_params.cw_array_7_89, cw_params.cw_array_7_90, cw_params.cw_array_7_91, cw_params.cw_array_7_92, cw_params.cw_array_7_93, cw_params.cw_array_7_94, cw_params.cw_array_7_95, cw_params.cw_array_7_96, cw_params.cw_array_7_97, cw_params.cw_array_7_98, cw_params.cw_array_7_99, cw_params.cw_array_7_100, cw_params.cw_array_7_101, cw_params.cw_array_7_102, cw_params.cw_array_7_103, cw_params.cw_array_7_104, cw_params.cw_array_7_105, cw_params.cw_array_7_106, cw_params.cw_array_7_107, cw_params.cw_array_7_108, cw_params.cw_array_7_109, cw_params.cw_array_7_110, cw_params.cw_array_7_111, cw_params.cw_array_7_112, cw_params.cw_array_7_113, cw_params.cw_array_7_114, cw_params.cw_array_7_115, cw_params.cw_array_7_116, cw_params.cw_array_7_117, cw_params.cw_array_7_118, cw_params.cw_array_7_119, cw_params.cw_array_7_120, cw_params.cw_array_7_121, cw_params.cw_array_7_122, cw_params.cw_array_7_123, cw_params.cw_array_7_124, cw_params.cw_array_7_125, cw_params.cw_array_7_126, cw_params.cw_array_7_127, cw_params.cw_array_7_128, cw_params.cw_array_7_129, cw_params.cw_array_7_130, cw_params.cw_array_7_131, cw_params.cw_array_7_132, cw_params.cw_array_7_133, cw_params.cw_array_7_134, cw_params.cw_array_7_135, cw_params.cw_array_7_136, cw_params.cw_array_7_137, cw_params.cw_array_7_138, cw_params.cw_array_7_139, cw_params.cw_array_7_140, cw_params.cw_array_7_141, cw_params.cw_array_7_142, cw_params.cw_array_7_143, cw_params.cw_array_7_144, cw_params.cw_array_7_145, cw_params.cw_array_7_146, cw_params.cw_array_7_147, cw_params.cw_array_7_148, cw_params.cw_array_7_149, cw_params.cw_array_7_150, cw_params.cw_array_7_151, cw_params.cw_array_7_152, cw_params.cw_array_7_153, cw_params.cw_array_7_154, cw_params.cw_array_7_155, cw_params.cw_array_7_156, cw_params.cw_array_7_157, cw_params.cw_array_7_158, cw_params.cw_array_7_159, cw_params.cw_array_7_160, cw_params.cw_array_7_161, cw_params.cw_array_7_162, cw_params.cw_array_7_163, cw_params.cw_array_7_164, cw_params.cw_array_7_165, cw_params.cw_array_7_166, cw_params.cw_array_7_167, cw_params.cw_array_7_168, cw_params.cw_array_7_169, cw_params.cw_array_7_170, cw_params.cw_array_7_171, cw_params.cw_array_7_172, cw_params.cw_array_7_173, cw_params.cw_array_7_174, cw_params.cw_array_7_175, cw_params.cw_array_7_176, cw_params.cw_array_7_177, cw_params.cw_array_7_178, cw_params.cw_array_7_179, cw_params.cw_array_7_180, cw_params.cw_array_7_181, cw_params.cw_array_7_182, cw_params.cw_array_7_183, cw_params.cw_array_7_184, cw_params.cw_array_7_185, cw_params.cw_array_7_186, cw_params.cw_array_7_187, cw_params.cw_array_7_188, cw_params.cw_array_7_189, cw_params.cw_array_7_190, cw_params.cw_array_7_191, cw_params.cw_array_7_192, cw_params.cw_array_7_193, cw_params.cw_array_7_194, cw_params.cw_array_7_195, cw_params.cw_array_7_196, cw_params.cw_array_7_197, cw_params.cw_array_7_198, cw_params.cw_array_7_199, cw_params.cw_array_7_200, cw_params.cw_array_7_201, cw_params.cw_array_7_202, cw_params.cw_array_7_203, cw_params.cw_array_7_204, cw_params.cw_array_7_205, cw_params.cw_array_7_206, cw_params.cw_array_7_207, cw_params.cw_array_7_208, cw_params.cw_array_7_209, cw_params.cw_array_7_210, cw_params.cw_array_7_211, cw_params.cw_array_7_212, cw_params.cw_array_7_213, cw_params.cw_array_7_214, cw_params.cw_array_7_215, cw_params.cw_array_7_216, cw_params.cw_array_7_217, cw_params.cw_array_7_218, cw_params.cw_array_7_219, cw_params.cw_array_7_220, cw_params.cw_array_7_221, cw_params.cw_array_7_222, cw_params.cw_array_7_223, cw_params.cw_array_7_224, cw_params.cw_array_7_225, cw_params.cw_array_7_226, cw_params.cw_array_7_227, cw_params.cw_array_7_228, cw_params.cw_array_7_229, cw_params.cw_array_7_230, cw_params.cw_array_7_231, cw_params.cw_array_7_232, cw_params.cw_array_7_233, cw_params.cw_array_7_234, cw_params.cw_array_7_235, cw_params.cw_array_7_236, cw_params.cw_array_7_237, cw_params.cw_array_7_238, cw_params.cw_array_7_239, cw_params.cw_array_7_240, cw_params.cw_array_7_241, cw_params.cw_array_7_242, cw_params.cw_array_7_243, cw_params.cw_array_7_244, cw_params.cw_array_7_245, cw_params.cw_array_7_246, cw_params.cw_array_7_247, cw_params.cw_array_7_248, cw_params.cw_array_7_249, cw_params.cw_array_7_250, cw_params.cw_array_7_251, cw_params.cw_array_7_252, cw_params.cw_array_7_253, cw_params.cw_array_7_254, cw_params.cw_array_7_255)[(v_i - 256i)];
  }
  if ((v_i < 650i)) {
    return array<u32, 138>(cw_params.cw_array_8_0, cw_params.cw_array_8_1, cw_params.cw_array_8_2, cw_params.cw_array_8_3, cw_params.cw_array_8_4, cw_params.cw_array_8_5, cw_params.cw_array_8_6, cw_params.cw_array_8_7, cw_params.cw_array_8_8, cw_params.cw_array_8_9, cw_params.cw_array_8_10, cw_params.cw_array_8_11, cw_params.cw_array_8_12, cw_params.cw_array_8_13, cw_params.cw_array_8_14, cw_params.cw_array_8_15, cw_params.cw_array_8_16, cw_params.cw_array_8_17, cw_params.cw_array_8_18, cw_params.cw_array_8_19, cw_params.cw_array_8_20, cw_params.cw_array_8_21, cw_params.cw_array_8_22, cw_params.cw_array_8_23, cw_params.cw_array_8_24, cw_params.cw_array_8_25, cw_params.cw_array_8_26, cw_params.cw_array_8_27, cw_params.cw_array_8_28, cw_params.cw_array_8_29, cw_params.cw_array_8_30, cw_params.cw_array_8_31, cw_params.cw_array_8_32, cw_params.cw_array_8_33, cw_params.cw_array_8_34, cw_params.cw_array_8_35, cw_params.cw_array_8_36, cw_params.cw_array_8_37, cw_params.cw_array_8_38, cw_params.cw_array_8_39, cw_params.cw_array_8_40, cw_params.cw_array_8_41, cw_params.cw_array_8_42, cw_params.cw_array_8_43, cw_params.cw_array_8_44, cw_params.cw_array_8_45, cw_params.cw_array_8_46, cw_params.cw_array_8_47, cw_params.cw_array_8_48, cw_params.cw_array_8_49, cw_params.cw_array_8_50, cw_params.cw_array_8_51, cw_params.cw_array_8_52, cw_params.cw_array_8_53, cw_params.cw_array_8_54, cw_params.cw_array_8_55, cw_params.cw_array_8_56, cw_params.cw_array_8_57, cw_params.cw_array_8_58, cw_params.cw_array_8_59, cw_params.cw_array_8_60, cw_params.cw_array_8_61, cw_params.cw_array_8_62, cw_params.cw_array_8_63, cw_params.cw_array_8_64, cw_params.cw_array_8_65, cw_params.cw_array_8_66, cw_params.cw_array_8_67, cw_params.cw_array_8_68, cw_params.cw_array_8_69, cw_params.cw_array_8_70, cw_params.cw_array_8_71, cw_params.cw_array_8_72, cw_params.cw_array_8_73, cw_params.cw_array_8_74, cw_params.cw_array_8_75, cw_params.cw_array_8_76, cw_params.cw_array_8_77, cw_params.cw_array_8_78, cw_params.cw_array_8_79, cw_params.cw_array_8_80, cw_params.cw_array_8_81, cw_params.cw_array_8_82, cw_params.cw_array_8_83, cw_params.cw_array_8_84, cw_params.cw_array_8_85, cw_params.cw_array_8_86, cw_params.cw_array_8_87, cw_params.cw_array_8_88, cw_params.cw_array_8_89, cw_params.cw_array_8_90, cw_params.cw_array_8_91, cw_params.cw_array_8_92, cw_params.cw_array_8_93, cw_params.cw_array_8_94, cw_params.cw_array_8_95, cw_params.cw_array_8_96, cw_params.cw_array_8_97, cw_params.cw_array_8_98, cw_params.cw_array_8_99, cw_params.cw_array_8_100, cw_params.cw_array_8_101, cw_params.cw_array_8_102, cw_params.cw_array_8_103, cw_params.cw_array_8_104, cw_params.cw_array_8_105, cw_params.cw_array_8_106, cw_params.cw_array_8_107, cw_params.cw_array_8_108, cw_params.cw_array_8_109, cw_params.cw_array_8_110, cw_params.cw_array_8_111, cw_params.cw_array_8_112, cw_params.cw_array_8_113, cw_params.cw_array_8_114, cw_params.cw_array_8_115, cw_params.cw_array_8_116, cw_params.cw_array_8_117, cw_params.cw_array_8_118, cw_params.cw_array_8_119, cw_params.cw_array_8_120, cw_params.cw_array_8_121, cw_params.cw_array_8_122, cw_params.cw_array_8_123, cw_params.cw_array_8_124, cw_params.cw_array_8_125, cw_params.cw_array_8_126, cw_params.cw_array_8_127, cw_params.cw_array_8_128, cw_params.cw_array_8_129, cw_params.cw_array_8_130, cw_params.cw_array_8_131, cw_params.cw_array_8_132, cw_params.cw_array_8_133, cw_params.cw_array_8_134, cw_params.cw_array_8_135, cw_params.cw_array_8_136, cw_params.cw_array_8_137)[(v_i - 512i)];
  }
  return 0u;
}
fn f_glyph(cw_arg_x: f32, cw_arg_y: f32, cw_arg_ch: i32, cw_arg_scale: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ch: i32 = cw_arg_ch;
  var v_scale: f32 = cw_arg_scale;
  var v_gx: f32 = cw_divide_f32(v_x, v_scale);
  var v_gy: f32 = cw_divide_f32(v_y, v_scale);
  var v_xx: i32 = i32(floor(v_gx));
  var v_yy: i32 = i32(floor(v_gy));
  if (((((((v_xx < 0i) || (v_xx >= 5i)) || (v_yy < 0i)) || (v_yy >= 7i)) || (v_ch < 32i)) || (v_ch >= 96i))) {
    return 0.0f;
  }
  var v_bit: i32 = (((v_yy * 5i) + 4i) - v_xx);
  var cw_tmp_0: u32;
  if ((v_bit < 32i)) {
    cw_tmp_0 = array<u32, 64>(cw_params.cw_array_0_0, cw_params.cw_array_0_1, cw_params.cw_array_0_2, cw_params.cw_array_0_3, cw_params.cw_array_0_4, cw_params.cw_array_0_5, cw_params.cw_array_0_6, cw_params.cw_array_0_7, cw_params.cw_array_0_8, cw_params.cw_array_0_9, cw_params.cw_array_0_10, cw_params.cw_array_0_11, cw_params.cw_array_0_12, cw_params.cw_array_0_13, cw_params.cw_array_0_14, cw_params.cw_array_0_15, cw_params.cw_array_0_16, cw_params.cw_array_0_17, cw_params.cw_array_0_18, cw_params.cw_array_0_19, cw_params.cw_array_0_20, cw_params.cw_array_0_21, cw_params.cw_array_0_22, cw_params.cw_array_0_23, cw_params.cw_array_0_24, cw_params.cw_array_0_25, cw_params.cw_array_0_26, cw_params.cw_array_0_27, cw_params.cw_array_0_28, cw_params.cw_array_0_29, cw_params.cw_array_0_30, cw_params.cw_array_0_31, cw_params.cw_array_0_32, cw_params.cw_array_0_33, cw_params.cw_array_0_34, cw_params.cw_array_0_35, cw_params.cw_array_0_36, cw_params.cw_array_0_37, cw_params.cw_array_0_38, cw_params.cw_array_0_39, cw_params.cw_array_0_40, cw_params.cw_array_0_41, cw_params.cw_array_0_42, cw_params.cw_array_0_43, cw_params.cw_array_0_44, cw_params.cw_array_0_45, cw_params.cw_array_0_46, cw_params.cw_array_0_47, cw_params.cw_array_0_48, cw_params.cw_array_0_49, cw_params.cw_array_0_50, cw_params.cw_array_0_51, cw_params.cw_array_0_52, cw_params.cw_array_0_53, cw_params.cw_array_0_54, cw_params.cw_array_0_55, cw_params.cw_array_0_56, cw_params.cw_array_0_57, cw_params.cw_array_0_58, cw_params.cw_array_0_59, cw_params.cw_array_0_60, cw_params.cw_array_0_61, cw_params.cw_array_0_62, cw_params.cw_array_0_63)[(v_ch - 32i)];
  } else {
    cw_tmp_0 = array<u32, 64>(cw_params.cw_array_1_0, cw_params.cw_array_1_1, cw_params.cw_array_1_2, cw_params.cw_array_1_3, cw_params.cw_array_1_4, cw_params.cw_array_1_5, cw_params.cw_array_1_6, cw_params.cw_array_1_7, cw_params.cw_array_1_8, cw_params.cw_array_1_9, cw_params.cw_array_1_10, cw_params.cw_array_1_11, cw_params.cw_array_1_12, cw_params.cw_array_1_13, cw_params.cw_array_1_14, cw_params.cw_array_1_15, cw_params.cw_array_1_16, cw_params.cw_array_1_17, cw_params.cw_array_1_18, cw_params.cw_array_1_19, cw_params.cw_array_1_20, cw_params.cw_array_1_21, cw_params.cw_array_1_22, cw_params.cw_array_1_23, cw_params.cw_array_1_24, cw_params.cw_array_1_25, cw_params.cw_array_1_26, cw_params.cw_array_1_27, cw_params.cw_array_1_28, cw_params.cw_array_1_29, cw_params.cw_array_1_30, cw_params.cw_array_1_31, cw_params.cw_array_1_32, cw_params.cw_array_1_33, cw_params.cw_array_1_34, cw_params.cw_array_1_35, cw_params.cw_array_1_36, cw_params.cw_array_1_37, cw_params.cw_array_1_38, cw_params.cw_array_1_39, cw_params.cw_array_1_40, cw_params.cw_array_1_41, cw_params.cw_array_1_42, cw_params.cw_array_1_43, cw_params.cw_array_1_44, cw_params.cw_array_1_45, cw_params.cw_array_1_46, cw_params.cw_array_1_47, cw_params.cw_array_1_48, cw_params.cw_array_1_49, cw_params.cw_array_1_50, cw_params.cw_array_1_51, cw_params.cw_array_1_52, cw_params.cw_array_1_53, cw_params.cw_array_1_54, cw_params.cw_array_1_55, cw_params.cw_array_1_56, cw_params.cw_array_1_57, cw_params.cw_array_1_58, cw_params.cw_array_1_59, cw_params.cw_array_1_60, cw_params.cw_array_1_61, cw_params.cw_array_1_62, cw_params.cw_array_1_63)[(v_ch - 32i)];
  }
  var v_bits: u32 = cw_tmp_0;
  var cw_tmp_1: i32;
  if ((v_bit < 32i)) {
    cw_tmp_1 = v_bit;
  } else {
    cw_tmp_1 = (v_bit - 32i);
  }
  var v_shift: i32 = cw_tmp_1;
  return f32(((v_bits >> u32(v_shift)) & 1u));
}
fn f_label(cw_arg_c: vec4<f32>, cw_arg_x: f32, cw_arg_y: f32, cw_arg_ox: f32, cw_arg_oy: f32, cw_arg_phrase: i32, cw_arg_scale: f32, cw_arg_tint: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: vec4<f32> = cw_arg_c;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ox: f32 = cw_arg_ox;
  var v_oy: f32 = cw_arg_oy;
  var v_phrase: i32 = cw_arg_phrase;
  var v_scale: f32 = cw_arg_scale;
  var v_tint: vec4<f32> = cw_arg_tint;
  var v_xx: f32 = (v_x - v_ox);
  var v_yy: f32 = (v_y - v_oy);
  var v_len: i32 = i32(array<u32, 65>(cw_params.cw_array_3_0, cw_params.cw_array_3_1, cw_params.cw_array_3_2, cw_params.cw_array_3_3, cw_params.cw_array_3_4, cw_params.cw_array_3_5, cw_params.cw_array_3_6, cw_params.cw_array_3_7, cw_params.cw_array_3_8, cw_params.cw_array_3_9, cw_params.cw_array_3_10, cw_params.cw_array_3_11, cw_params.cw_array_3_12, cw_params.cw_array_3_13, cw_params.cw_array_3_14, cw_params.cw_array_3_15, cw_params.cw_array_3_16, cw_params.cw_array_3_17, cw_params.cw_array_3_18, cw_params.cw_array_3_19, cw_params.cw_array_3_20, cw_params.cw_array_3_21, cw_params.cw_array_3_22, cw_params.cw_array_3_23, cw_params.cw_array_3_24, cw_params.cw_array_3_25, cw_params.cw_array_3_26, cw_params.cw_array_3_27, cw_params.cw_array_3_28, cw_params.cw_array_3_29, cw_params.cw_array_3_30, cw_params.cw_array_3_31, cw_params.cw_array_3_32, cw_params.cw_array_3_33, cw_params.cw_array_3_34, cw_params.cw_array_3_35, cw_params.cw_array_3_36, cw_params.cw_array_3_37, cw_params.cw_array_3_38, cw_params.cw_array_3_39, cw_params.cw_array_3_40, cw_params.cw_array_3_41, cw_params.cw_array_3_42, cw_params.cw_array_3_43, cw_params.cw_array_3_44, cw_params.cw_array_3_45, cw_params.cw_array_3_46, cw_params.cw_array_3_47, cw_params.cw_array_3_48, cw_params.cw_array_3_49, cw_params.cw_array_3_50, cw_params.cw_array_3_51, cw_params.cw_array_3_52, cw_params.cw_array_3_53, cw_params.cw_array_3_54, cw_params.cw_array_3_55, cw_params.cw_array_3_56, cw_params.cw_array_3_57, cw_params.cw_array_3_58, cw_params.cw_array_3_59, cw_params.cw_array_3_60, cw_params.cw_array_3_61, cw_params.cw_array_3_62, cw_params.cw_array_3_63, cw_params.cw_array_3_64)[v_phrase]);
  if (((((v_xx < 0.0f) || (v_yy < 0.0f)) || (v_yy >= (7.0f * v_scale))) || (v_xx >= ((f32(v_len) * 6.0f) * v_scale)))) {
    return v_c;
  }
  var v_pos: i32 = i32(floor(cw_divide_f32(v_xx, (6.0f * v_scale))));
  var v_idx: i32 = (i32(array<u32, 65>(cw_params.cw_array_2_0, cw_params.cw_array_2_1, cw_params.cw_array_2_2, cw_params.cw_array_2_3, cw_params.cw_array_2_4, cw_params.cw_array_2_5, cw_params.cw_array_2_6, cw_params.cw_array_2_7, cw_params.cw_array_2_8, cw_params.cw_array_2_9, cw_params.cw_array_2_10, cw_params.cw_array_2_11, cw_params.cw_array_2_12, cw_params.cw_array_2_13, cw_params.cw_array_2_14, cw_params.cw_array_2_15, cw_params.cw_array_2_16, cw_params.cw_array_2_17, cw_params.cw_array_2_18, cw_params.cw_array_2_19, cw_params.cw_array_2_20, cw_params.cw_array_2_21, cw_params.cw_array_2_22, cw_params.cw_array_2_23, cw_params.cw_array_2_24, cw_params.cw_array_2_25, cw_params.cw_array_2_26, cw_params.cw_array_2_27, cw_params.cw_array_2_28, cw_params.cw_array_2_29, cw_params.cw_array_2_30, cw_params.cw_array_2_31, cw_params.cw_array_2_32, cw_params.cw_array_2_33, cw_params.cw_array_2_34, cw_params.cw_array_2_35, cw_params.cw_array_2_36, cw_params.cw_array_2_37, cw_params.cw_array_2_38, cw_params.cw_array_2_39, cw_params.cw_array_2_40, cw_params.cw_array_2_41, cw_params.cw_array_2_42, cw_params.cw_array_2_43, cw_params.cw_array_2_44, cw_params.cw_array_2_45, cw_params.cw_array_2_46, cw_params.cw_array_2_47, cw_params.cw_array_2_48, cw_params.cw_array_2_49, cw_params.cw_array_2_50, cw_params.cw_array_2_51, cw_params.cw_array_2_52, cw_params.cw_array_2_53, cw_params.cw_array_2_54, cw_params.cw_array_2_55, cw_params.cw_array_2_56, cw_params.cw_array_2_57, cw_params.cw_array_2_58, cw_params.cw_array_2_59, cw_params.cw_array_2_60, cw_params.cw_array_2_61, cw_params.cw_array_2_62, cw_params.cw_array_2_63, cw_params.cw_array_2_64)[v_phrase]) + v_pos);
  var v_word: u32 = f_textWord((v_idx / 4i), cw_thread, cw_block, cw_grid);
  var v_ch: i32 = i32(((v_word >> u32(((v_idx % 4i) * 8i))) & 255u));
  return f_blend(v_c, v_tint, f_glyph((v_xx - ((f32(v_pos) * 6.0f) * v_scale)), v_yy, v_ch, v_scale, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
}
fn f_centered(cw_arg_c: vec4<f32>, cw_arg_x: f32, cw_arg_y: f32, cw_arg_cx: f32, cw_arg_oy: f32, cw_arg_phrase: i32, cw_arg_scale: f32, cw_arg_tint: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: vec4<f32> = cw_arg_c;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_cx: f32 = cw_arg_cx;
  var v_oy: f32 = cw_arg_oy;
  var v_phrase: i32 = cw_arg_phrase;
  var v_scale: f32 = cw_arg_scale;
  var v_tint: vec4<f32> = cw_arg_tint;
  return f_label(v_c, v_x, v_y, (v_cx - ((f32(array<u32, 65>(cw_params.cw_array_3_0, cw_params.cw_array_3_1, cw_params.cw_array_3_2, cw_params.cw_array_3_3, cw_params.cw_array_3_4, cw_params.cw_array_3_5, cw_params.cw_array_3_6, cw_params.cw_array_3_7, cw_params.cw_array_3_8, cw_params.cw_array_3_9, cw_params.cw_array_3_10, cw_params.cw_array_3_11, cw_params.cw_array_3_12, cw_params.cw_array_3_13, cw_params.cw_array_3_14, cw_params.cw_array_3_15, cw_params.cw_array_3_16, cw_params.cw_array_3_17, cw_params.cw_array_3_18, cw_params.cw_array_3_19, cw_params.cw_array_3_20, cw_params.cw_array_3_21, cw_params.cw_array_3_22, cw_params.cw_array_3_23, cw_params.cw_array_3_24, cw_params.cw_array_3_25, cw_params.cw_array_3_26, cw_params.cw_array_3_27, cw_params.cw_array_3_28, cw_params.cw_array_3_29, cw_params.cw_array_3_30, cw_params.cw_array_3_31, cw_params.cw_array_3_32, cw_params.cw_array_3_33, cw_params.cw_array_3_34, cw_params.cw_array_3_35, cw_params.cw_array_3_36, cw_params.cw_array_3_37, cw_params.cw_array_3_38, cw_params.cw_array_3_39, cw_params.cw_array_3_40, cw_params.cw_array_3_41, cw_params.cw_array_3_42, cw_params.cw_array_3_43, cw_params.cw_array_3_44, cw_params.cw_array_3_45, cw_params.cw_array_3_46, cw_params.cw_array_3_47, cw_params.cw_array_3_48, cw_params.cw_array_3_49, cw_params.cw_array_3_50, cw_params.cw_array_3_51, cw_params.cw_array_3_52, cw_params.cw_array_3_53, cw_params.cw_array_3_54, cw_params.cw_array_3_55, cw_params.cw_array_3_56, cw_params.cw_array_3_57, cw_params.cw_array_3_58, cw_params.cw_array_3_59, cw_params.cw_array_3_60, cw_params.cw_array_3_61, cw_params.cw_array_3_62, cw_params.cw_array_3_63, cw_params.cw_array_3_64)[v_phrase]) * 3.0f) * v_scale)), v_oy, v_phrase, v_scale, v_tint, cw_thread, cw_block, cw_grid);
}
fn f_number(cw_arg_c: vec4<f32>, cw_arg_x: f32, cw_arg_y: f32, cw_arg_ox: f32, cw_arg_oy: f32, cw_arg_value: i32, cw_arg_digits: i32, cw_arg_scale: f32, cw_arg_tint: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: vec4<f32> = cw_arg_c;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ox: f32 = cw_arg_ox;
  var v_oy: f32 = cw_arg_oy;
  var v_value: i32 = cw_arg_value;
  var v_digits: i32 = cw_arg_digits;
  var v_scale: f32 = cw_arg_scale;
  var v_tint: vec4<f32> = cw_arg_tint;
  var v_xx: f32 = (v_x - v_ox);
  var v_yy: f32 = (v_y - v_oy);
  if (((((v_xx < 0.0f) || (v_yy < 0.0f)) || (v_yy >= (7.0f * v_scale))) || (v_xx >= ((f32(v_digits) * 6.0f) * v_scale)))) {
    return v_c;
  }
  var v_pos: i32 = i32(floor(cw_divide_f32(v_xx, (6.0f * v_scale))));
  var v_power: i32 = 1i;
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 6i)) { break; }
      if ((v_j < ((v_digits - v_pos) - 1i))) {
        v_power = (v_power * 10i);
      }
      continuing {
        v_j += i32(1);
      }
    }
  }
  var v_ch: i32 = (48i + ((v_value / v_power) % 10i));
  return f_blend(v_c, v_tint, f_glyph((v_xx - ((f32(v_pos) * 6.0f) * v_scale)), v_yy, v_ch, v_scale, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
}
fn f_titleBit(cw_arg_x: i32, cw_arg_y: i32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: i32 = cw_arg_x;
  var v_y: i32 = cw_arg_y;
  if (((((v_x < 0i) || (v_y < 0i)) || (v_x >= 408i)) || (v_y >= 50i))) {
    return 0.0f;
  }
  return f32(((f_titleWord(((v_y * 13i) + (v_x / 32i)), cw_thread, cw_block, cw_grid) >> u32((v_x % 32i))) & 1u));
}
fn f_titleMask(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_xx: i32 = i32(floor(v_x));
  var v_yy: i32 = i32(floor(v_y));
  var v_fx: f32 = f_frac(v_x, cw_thread, cw_block, cw_grid);
  var v_fy: f32 = f_frac(v_y, cw_thread, cw_block, cw_grid);
  return f_mixf(f_mixf(f_titleBit(v_xx, v_yy, cw_thread, cw_block, cw_grid), f_titleBit((v_xx + 1i), v_yy, cw_thread, cw_block, cw_grid), v_fx, cw_thread, cw_block, cw_grid), f_mixf(f_titleBit(v_xx, (v_yy + 1i), cw_thread, cw_block, cw_grid), f_titleBit((v_xx + 1i), (v_yy + 1i), cw_thread, cw_block, cw_grid), v_fx, cw_thread, cw_block, cw_grid), v_fy, cw_thread, cw_block, cw_grid);
}
fn f_panel(cw_arg_c: vec4<f32>, cw_arg_x: f32, cw_arg_y: f32, cw_arg_cx: f32, cw_arg_cy: f32, cw_arg_w: f32, cw_arg_h: f32, cw_arg_light: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: vec4<f32> = cw_arg_c;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_cx: f32 = cw_arg_cx;
  var v_cy: f32 = cw_arg_cy;
  var v_w: f32 = cw_arg_w;
  var v_h: f32 = cw_arg_h;
  var v_light: f32 = cw_arg_light;
  var v_d: f32 = f_boxd((v_x - v_cx), (v_y - v_cy), (v_w * 0.5f), (v_h * 0.5f), cw_thread, cw_block, cw_grid);
  v_c = f_blend(v_c, f_color(0.023f, 0.028f, 0.029f, cw_thread, cw_block, cw_grid), (f_ink(v_d, 1.0f, cw_thread, cw_block, cw_grid) * 0.95f), cw_thread, cw_block, cw_grid);
  return f_blend(v_c, f_color((0.4f * v_light), (0.34f * v_light), (0.24f * v_light), cw_thread, cw_block, cw_grid), f_ink((abs(v_d) - 0.65f), 1.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
}
fn f_relic(cw_arg_c: vec4<f32>, cw_arg_x: f32, cw_arg_y: f32, cw_arg_kind: i32, cw_arg_gold: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: vec4<f32> = cw_arg_c;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_kind: i32 = cw_arg_kind;
  var v_gold: vec4<f32> = cw_arg_gold;
  var v_d: f32 = 1000.0f;
  if ((v_kind == 0i)) {
    v_d = min((f_segment(v_x, v_y, (-12.0f), 15.0f, 12.0f, (-15.0f), cw_thread, cw_block, cw_grid) - 2.5f), (f_segment(v_x, v_y, (-10.0f), (-7.0f), 10.0f, 7.0f, cw_thread, cw_block, cw_grid) - 1.8f));
  }
  if ((v_kind == 1i)) {
    v_d = min((abs((f_len2(v_x, v_y, cw_thread, cw_block, cw_grid) - 16.0f)) - 1.0f), (f_segment(v_x, v_y, 0.0f, 0.0f, 8.0f, (-11.0f), cw_thread, cw_block, cw_grid) - 1.6f));
  }
  if ((v_kind == 2i)) {
    v_d = max((abs(v_x) - 15.0f), (abs((v_y + 2.0f)) - 10.0f));
  }
  if ((v_kind == 2i)) {
    v_d = min((abs((f_len2(v_x, (v_y + 9.0f), cw_thread, cw_block, cw_grid) - 12.0f)) - 1.3f), abs((f_segment(v_x, v_y, (-11.0f), (-9.0f), 0.0f, 17.0f, cw_thread, cw_block, cw_grid) - 1.0f)));
  }
  if ((v_kind == 3i)) {
    {
      var v_k: i32 = (-1i);
      loop {
        if (!(v_k <= 1i)) { break; }
        v_d = min(v_d, (f_segment(v_x, v_y, (f32(v_k) * 5.0f), 15.0f, (f32(v_k) * 14.0f), (-15.0f), cw_thread, cw_block, cw_grid) - 1.6f));
        continuing {
          v_k += i32(1);
        }
      }
    }
  }
  if ((v_kind == 4i)) {
    v_d = (abs((f_len2(v_x, v_y, cw_thread, cw_block, cw_grid) - 17.0f)) - 0.8f);
    v_d = min(v_d, (f_segment(v_x, v_y, (-16.0f), 15.0f, 16.0f, (-15.0f), cw_thread, cw_block, cw_grid) - 1.8f));
  }
  if ((v_kind == 5i)) {
    v_d = min((f_segment(v_x, v_y, (-11.0f), 15.0f, 0.0f, (-17.0f), cw_thread, cw_block, cw_grid) - 2.0f), (f_segment(v_x, v_y, 0.0f, (-17.0f), 12.0f, 8.0f, cw_thread, cw_block, cw_grid) - 2.0f));
  }
  return f_blend(v_c, v_gold, f_ink(v_d, 1.2f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
}

@compute @workgroup_size(8, 8, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_ix: i32 = i32(((cw_block.x * cw_block_size.x) + cw_thread.x));
  var v_iy: i32 = i32(((cw_block.y * cw_block_size.y) + cw_thread.y));
  if (((v_ix >= cw_params.p_width) || (v_iy >= cw_params.p_height))) {
    return;
  }
  var v_factor: f32 = cw_divide_f32(f32(cw_params.p_height), 720.0f);
  var v_x: f32 = cw_divide_f32(f32(v_ix), v_factor);
  var v_y: f32 = cw_divide_f32(f32(v_iy), v_factor);
  var v_vw: f32 = cw_divide_f32(f32(cw_params.p_width), v_factor);
  var v_cx: f32 = (v_vw * 0.5f);
  let cw_argument_index_2 = ((v_iy * cw_params.p_width) + v_ix);
  var v_c: vec4<f32> = f_unrgba(b_Pixels[cw_argument_index_2], cw_thread, cw_block, cw_grid);
  var v_gold: vec4<f32> = f_color(0.68f, 0.58f, 0.39f, cw_thread, cw_block, cw_grid);
  var v_ivory: vec4<f32> = f_color(0.85f, 0.84f, 0.75f, cw_thread, cw_block, cw_grid);
  var v_dim: vec4<f32> = f_color(0.42f, 0.46f, 0.43f, cw_thread, cw_block, cw_grid);
  var v_mode: i32 = i32(b_S[8i]);
  var v_mouseX: f32 = (((b_I[2i] + 1.0f) * v_vw) * 0.5f);
  var v_mouseY: f32 = ((b_I[3i] + 1.0f) * 360.0f);
  if ((v_mode != 0i)) {
    var v_shade: f32 = (((1.0f - f_smooth01(0.0f, 58.0f, v_y, cw_thread, cw_block, cw_grid)) * 0.38f) + (f_smooth01(668.0f, 720.0f, v_y, cw_thread, cw_block, cw_grid) * 0.32f));
    v_c = f_blend(v_c, f_color(0.016f, 0.02f, 0.022f, cw_thread, cw_block, cw_grid), v_shade, cw_thread, cw_block, cw_grid);
    v_c = f_label(v_c, v_x, v_y, 28.0f, 25.0f, 10i, 1.4f, v_gold, cw_thread, cw_block, cw_grid);
    v_c = f_number(v_c, v_x, v_y, 28.0f, 44.0f, i32(b_S[4i]), 3i, 2.0f, v_ivory, cw_thread, cw_block, cw_grid);
    v_c = f_blend(v_c, v_dim, f_glyph((v_x - 69.0f), (v_y - 47.0f), 47i, 1.5f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_number(v_c, v_x, v_y, 84.0f, 47.0f, i32(b_S[5i]), 3i, 1.5f, v_dim, cw_thread, cw_block, cw_grid);
    if (((((v_y >= 70.0f) && (v_y < 76.0f)) && (v_x >= 28.0f)) && (v_x < 230.0f))) {
      v_c = f_color(0.16f, 0.08f, 0.065f, cw_thread, cw_block, cw_grid);
      if ((v_x < (28.0f + cw_divide_f32((202.0f * b_S[4i]), b_S[5i])))) {
        v_c = f_color(0.62f, 0.2f, 0.15f, cw_thread, cw_block, cw_grid);
      }
    }
    if (((((v_y >= 81.0f) && (v_y < 83.0f)) && (v_x >= 28.0f)) && (v_x < 230.0f))) {
      v_c = f_color(0.12f, 0.14f, 0.13f, cw_thread, cw_block, cw_grid);
      if ((v_x < (28.0f + (202.0f * (1.0f - cw_divide_f32(b_S[13i], 2.1f)))))) {
        v_c = f_color(0.38f, 0.49f, 0.44f, cw_thread, cw_block, cw_grid);
      }
    }
    var v_minutes: i32 = (i32(b_S[6i]) / 60i);
    var v_seconds: i32 = (i32(b_S[6i]) % 60i);
    v_c = f_number(v_c, v_x, v_y, (v_cx - 48.0f), 27.0f, v_minutes, 2i, 2.8f, v_ivory, cw_thread, cw_block, cw_grid);
    v_c = f_blend(v_c, v_gold, f_glyph((v_x - (v_cx - 9.0f)), (v_y - 27.0f), 58i, 2.8f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_number(v_c, v_x, v_y, (v_cx + 12.0f), 27.0f, v_seconds, 2i, 2.8f, v_ivory, cw_thread, cw_block, cw_grid);
    v_c = f_centered(v_c, v_x, v_y, v_cx, 57.0f, 6i, 1.15f, v_dim, cw_thread, cw_block, cw_grid);
    v_c = f_label(v_c, v_x, v_y, (v_vw - 129.0f), 26.0f, 11i, 1.4f, v_gold, cw_thread, cw_block, cw_grid);
    v_c = f_number(v_c, v_x, v_y, (v_vw - 128.0f), 45.0f, i32(b_S[12i]), 5i, 2.0f, v_ivory, cw_thread, cw_block, cw_grid);
    v_c = f_label(v_c, v_x, v_y, 28.0f, 672.0f, 12i, 1.8f, v_gold, cw_thread, cw_block, cw_grid);
    v_c = f_number(v_c, v_x, v_y, 65.0f, 672.0f, i32(b_S[10i]), 2i, 1.8f, v_ivory, cw_thread, cw_block, cw_grid);
    v_c = f_label(v_c, v_x, v_y, 111.0f, 675.0f, 63i, 1.2f, v_dim, cw_thread, cw_block, cw_grid);
    v_c = f_number(v_c, v_x, v_y, 163.0f, 675.0f, i32(b_S[9i]), 3i, 1.2f, v_ivory, cw_thread, cw_block, cw_grid);
    if (((((v_y >= 710.0f) && (v_y < 713.0f)) && (v_x >= 28.0f)) && (v_x < (v_vw - 28.0f)))) {
      v_c = f_color(0.14f, 0.14f, 0.11f, cw_thread, cw_block, cw_grid);
      if ((v_x < (28.0f + cw_divide_f32(((v_vw - 56.0f) * b_S[9i]), b_S[11i])))) {
        v_c = v_gold;
      }
    }
    {
      var v_k: i32 = 0i;
      loop {
        if (!(v_k < 3i)) { break; }
        var v_bx: f32 = (v_cx + (f32((v_k - 1i)) * 90.0f));
        var cw_tmp_4: f32;
        if ((v_k == 0i)) {
          cw_tmp_4 = cw_divide_f32(b_S[13i], 2.1f);
        } else {
          var cw_tmp_3: f32;
          if ((v_k == 1i)) {
            cw_tmp_3 = cw_divide_f32(b_S[17i], 0.95f);
          } else {
            cw_tmp_3 = cw_divide_f32(b_S[20i], 7.0f);
          }
          cw_tmp_4 = cw_tmp_3;
        }
        var v_cooldown: f32 = cw_tmp_4;
        var cw_tmp_5: f32;
        if ((v_cooldown > 0.0f)) {
          cw_tmp_5 = 0.5f;
        } else {
          cw_tmp_5 = 1.0f;
        }
        v_c = f_panel(v_c, v_x, v_y, v_bx, 655.0f, 42.0f, 36.0f, cw_tmp_5, cw_thread, cw_block, cw_grid);
        if (((((v_y >= 637.0f) && (v_y < 673.0f)) && (abs((v_x - v_bx)) < 20.0f)) && (v_y > (673.0f - (v_cooldown * 36.0f))))) {
          v_c = f_blend(v_c, f_color(0.12f, 0.14f, 0.14f, cw_thread, cw_block, cw_grid), 0.7f, cw_thread, cw_block, cw_grid);
        }
        var cw_tmp_6: f32;
        if ((v_k == 0i)) {
          cw_tmp_6 = 0.9f;
        } else {
          cw_tmp_6 = 1.3f;
        }
        var cw_tmp_7: vec4<f32>;
        if ((v_cooldown > 0.0f)) {
          cw_tmp_7 = v_dim;
        } else {
          cw_tmp_7 = v_ivory;
        }
        v_c = f_centered(v_c, v_x, v_y, v_bx, 650.0f, (60i + v_k), cw_tmp_6, cw_tmp_7, cw_thread, cw_block, cw_grid);
        v_c = f_centered(v_c, v_x, v_y, v_bx, 682.0f, (13i + v_k), 1.0f, v_dim, cw_thread, cw_block, cw_grid);
        continuing {
          v_k += i32(1);
        }
      }
    }
    var cw_tmp_9: i32;
    if ((b_S[45i] < 0.5f)) {
      cw_tmp_9 = 18i;
    } else {
      var cw_tmp_8: i32;
      if ((b_Brain[0i] < 1.0f)) {
        cw_tmp_8 = 16i;
      } else {
        cw_tmp_8 = 17i;
      }
      cw_tmp_9 = cw_tmp_8;
    }
    var v_status: i32 = cw_tmp_9;
    v_c = f_label(v_c, v_x, v_y, (v_vw - 203.0f), 657.0f, v_status, 1.2f, v_gold, cw_thread, cw_block, cw_grid);
    v_c = f_label(v_c, v_x, v_y, (v_vw - 203.0f), 678.0f, 19i, 1.0f, v_dim, cw_thread, cw_block, cw_grid);
    let cw_argument_index_10 = 13i;
    v_c = f_number(v_c, v_x, v_y, (v_vw - 144.0f), 678.0f, i32(max(1.0f, b_Brain[cw_argument_index_10])), 2i, 1.0f, v_ivory, cw_thread, cw_block, cw_grid);
    if ((v_mode == 1i)) {
      var v_d: f32 = (abs((f_len2((v_x - v_mouseX), (v_y - v_mouseY), cw_thread, cw_block, cw_grid) - 6.0f)) - 0.55f);
      v_c = f_blend(v_c, v_ivory, (f_ink(v_d, 1.0f, cw_thread, cw_block, cw_grid) * 0.65f), cw_thread, cw_block, cw_grid);
    }
  }
  if ((v_mode == 0i)) {
    v_c = f_blend(v_c, f_color(0.012f, 0.018f, 0.021f, cw_thread, cw_block, cw_grid), 0.66f, cw_thread, cw_block, cw_grid);
    var v_sx: f32 = (v_x - v_cx);
    var v_sy: f32 = (v_y - 152.0f);
    var v_sigil: f32 = (min(abs((f_len2(v_sx, v_sy, cw_thread, cw_block, cw_grid) - 33.0f)), abs((f_len2(v_sx, v_sy, cw_thread, cw_block, cw_grid) - 38.0f))) - 0.6f);
    v_sigil = min(v_sigil, (f_segment(v_sx, v_sy, 0.0f, (-49.0f), 0.0f, 47.0f, cw_thread, cw_block, cw_grid) - 0.7f));
    v_sigil = min(v_sigil, (f_segment(v_sx, v_sy, (-25.0f), 22.0f, 0.0f, (-25.0f), cw_thread, cw_block, cw_grid) - 0.6f));
    v_sigil = min(v_sigil, (f_segment(v_sx, v_sy, 0.0f, (-25.0f), 25.0f, 22.0f, cw_thread, cw_block, cw_grid) - 0.6f));
    v_c = f_blend(v_c, v_gold, (f_ink(v_sigil, 1.1f, cw_thread, cw_block, cw_grid) * 0.85f), cw_thread, cw_block, cw_grid);
    var v_titleScale: f32 = min(1.28f, cw_divide_f32((v_vw - 46.0f), f32(408i)));
    var v_titleX: f32 = (cw_divide_f32((v_x - v_cx), v_titleScale) + (f32(408i) * 0.5f));
    var v_titleY: f32 = cw_divide_f32((v_y - 227.0f), v_titleScale);
    v_c = f_blend(v_c, f_color(0.82f, 0.8f, 0.68f, cw_thread, cw_block, cw_grid), f_titleMask(v_titleX, v_titleY, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var cw_tmp_11: f32;
    if ((v_vw < 700.0f)) {
      cw_tmp_11 = 1.4f;
    } else {
      cw_tmp_11 = 1.85f;
    }
    v_c = f_centered(v_c, v_x, v_y, v_cx, 315.0f, 0i, cw_tmp_11, v_gold, cw_thread, cw_block, cw_grid);
    v_c = f_centered(v_c, v_x, v_y, v_cx, 381.0f, 2i, 1.3f, v_ivory, cw_thread, cw_block, cw_grid);
    v_c = f_centered(v_c, v_x, v_y, v_cx, 404.0f, 3i, 1.3f, v_dim, cw_thread, cw_block, cw_grid);
    var v_hover: bool = ((abs((v_mouseX - v_cx)) < 151.0f) && (abs((v_mouseY - 473.0f)) < 25.0f));
    var cw_tmp_12: f32;
    if (v_hover) {
      cw_tmp_12 = 1.6f;
    } else {
      cw_tmp_12 = 1.0f;
    }
    v_c = f_panel(v_c, v_x, v_y, v_cx, 473.0f, 302.0f, 51.0f, cw_tmp_12, cw_thread, cw_block, cw_grid);
    var cw_tmp_13: vec4<f32>;
    if (v_hover) {
      cw_tmp_13 = v_ivory;
    } else {
      cw_tmp_13 = v_gold;
    }
    v_c = f_centered(v_c, v_x, v_y, v_cx, 466.0f, 4i, 1.8f, cw_tmp_13, cw_thread, cw_block, cw_grid);
    v_c = f_centered(v_c, v_x, v_y, v_cx, 515.0f, 5i, 1.0f, v_dim, cw_thread, cw_block, cw_grid);
    var cw_tmp_14: f32;
    if ((v_vw < 700.0f)) {
      cw_tmp_14 = 1.0f;
    } else {
      cw_tmp_14 = 1.25f;
    }
    v_c = f_centered(v_c, v_x, v_y, v_cx, 579.0f, 7i, cw_tmp_14, v_dim, cw_thread, cw_block, cw_grid);
    var cw_tmp_15: f32;
    if ((v_vw < 700.0f)) {
      cw_tmp_15 = 1.0f;
    } else {
      cw_tmp_15 = 1.25f;
    }
    v_c = f_centered(v_c, v_x, v_y, v_cx, 600.0f, 8i, cw_tmp_15, v_dim, cw_thread, cw_block, cw_grid);
    v_c = f_centered(v_c, v_x, v_y, v_cx, 647.0f, 6i, 1.15f, v_gold, cw_thread, cw_block, cw_grid);
    v_c = f_centered(v_c, v_x, v_y, v_cx, 687.0f, 9i, 0.9f, v_dim, cw_thread, cw_block, cw_grid);
  }
  if (((((v_mode == 2i) || (v_mode == 3i)) || (v_mode == 4i)) || (v_mode == 5i))) {
    v_c = f_blend(v_c, f_color(0.009f, 0.013f, 0.015f, cw_thread, cw_block, cw_grid), 0.84f, cw_thread, cw_block, cw_grid);
    if ((v_mode == 3i)) {
      var cw_tmp_16: f32;
      if ((v_vw < 850.0f)) {
        cw_tmp_16 = 2.6f;
      } else {
        cw_tmp_16 = 3.2f;
      }
      v_c = f_centered(v_c, v_x, v_y, v_cx, 150.0f, 21i, cw_tmp_16, v_ivory, cw_thread, cw_block, cw_grid);
      var cw_tmp_17: f32;
      if ((v_vw < 850.0f)) {
        cw_tmp_17 = 1.0f;
      } else {
        cw_tmp_17 = 1.2f;
      }
      v_c = f_centered(v_c, v_x, v_y, v_cx, 192.0f, 22i, cw_tmp_17, v_dim, cw_thread, cw_block, cw_grid);
      {
        var v_k: i32 = 0i;
        loop {
          if (!(v_k < 3i)) { break; }
          var cw_tmp_18: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_18 = v_cx;
          } else {
            cw_tmp_18 = (v_cx + (f32((v_k - 1i)) * 280.0f));
          }
          var v_bx: f32 = cw_tmp_18;
          var cw_tmp_19: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_19 = (282.0f + (f32(v_k) * 133.0f));
          } else {
            cw_tmp_19 = 390.0f;
          }
          var v_by: f32 = cw_tmp_19;
          var cw_tmp_20: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_20 = (v_vw - 40.0f);
          } else {
            cw_tmp_20 = 254.0f;
          }
          var v_ww: f32 = cw_tmp_20;
          var cw_tmp_21: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_21 = 116.0f;
          } else {
            cw_tmp_21 = 234.0f;
          }
          var v_hh: f32 = cw_tmp_21;
          var v_hover: bool = ((abs((v_mouseX - v_bx)) < (v_ww * 0.5f)) && (abs((v_mouseY - v_by)) < (v_hh * 0.5f)));
          var cw_tmp_22: f32;
          if (v_hover) {
            cw_tmp_22 = 1.8f;
          } else {
            cw_tmp_22 = 0.8f;
          }
          v_c = f_panel(v_c, v_x, v_y, v_bx, v_by, v_ww, v_hh, cw_tmp_22, cw_thread, cw_block, cw_grid);
          var v_kind: i32 = (((i32(b_S[10i]) * 3i) + v_k) % 6i);
          var cw_tmp_23: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_23 = ((v_bx - (v_ww * 0.5f)) + 42.0f);
          } else {
            cw_tmp_23 = v_bx;
          }
          var v_iconx: f32 = cw_tmp_23;
          var cw_tmp_24: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_24 = v_by;
          } else {
            cw_tmp_24 = (v_by - 62.0f);
          }
          var v_icony: f32 = cw_tmp_24;
          v_c = f_relic(v_c, (v_x - v_iconx), (v_y - v_icony), v_kind, v_gold, cw_thread, cw_block, cw_grid);
          var cw_tmp_25: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_25 = (v_bx + 18.0f);
          } else {
            cw_tmp_25 = v_bx;
          }
          var v_textx: f32 = cw_tmp_25;
          var cw_tmp_26: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_26 = (v_by - 28.0f);
          } else {
            cw_tmp_26 = (v_by - 9.0f);
          }
          var v_texty: f32 = cw_tmp_26;
          var cw_tmp_27: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_27 = 1.5f;
          } else {
            cw_tmp_27 = 1.85f;
          }
          v_c = f_centered(v_c, v_x, v_y, v_textx, v_texty, (23i + v_kind), cw_tmp_27, v_ivory, cw_thread, cw_block, cw_grid);
          var cw_tmp_28: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_28 = 0.95f;
          } else {
            cw_tmp_28 = 1.15f;
          }
          v_c = f_centered(v_c, v_x, v_y, v_textx, (v_texty + 29.0f), (29i + v_kind), cw_tmp_28, v_dim, cw_thread, cw_block, cw_grid);
          var cw_tmp_29: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_29 = (v_by + 31.0f);
          } else {
            cw_tmp_29 = (v_by + 73.0f);
          }
          var v_keyy: f32 = cw_tmp_29;
          v_c = f_label(v_c, v_x, v_y, (v_textx - 27.0f), v_keyy, 35i, 1.1f, v_gold, cw_thread, cw_block, cw_grid);
          v_c = f_number(v_c, v_x, v_y, (v_textx + 17.0f), v_keyy, (v_k + 1i), 1i, 1.1f, v_ivory, cw_thread, cw_block, cw_grid);
          continuing {
            v_k += i32(1);
          }
        }
      }
    } else {
      if ((v_mode == 2i)) {
        var cw_tmp_30: f32;
        if ((v_vw < 700.0f)) {
          cw_tmp_30 = 2.5f;
        } else {
          cw_tmp_30 = 3.6f;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 210.0f, 36i, cw_tmp_30, v_ivory, cw_thread, cw_block, cw_grid);
        v_c = f_centered(v_c, v_x, v_y, v_cx, 283.0f, 37i, 1.5f, v_gold, cw_thread, cw_block, cw_grid);
        var cw_tmp_31: f32;
        if ((v_vw < 700.0f)) {
          cw_tmp_31 = 1.0f;
        } else {
          cw_tmp_31 = 1.35f;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 366.0f, 51i, cw_tmp_31, v_dim, cw_thread, cw_block, cw_grid);
        var cw_tmp_32: f32;
        if ((v_vw < 700.0f)) {
          cw_tmp_32 = 1.0f;
        } else {
          cw_tmp_32 = 1.35f;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 400.0f, 52i, cw_tmp_32, v_dim, cw_thread, cw_block, cw_grid);
        var cw_tmp_33: f32;
        if ((v_vw < 700.0f)) {
          cw_tmp_33 = 1.0f;
        } else {
          cw_tmp_33 = 1.35f;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 434.0f, 53i, cw_tmp_33, v_dim, cw_thread, cw_block, cw_grid);
        v_c = f_centered(v_c, v_x, v_y, v_cx, 501.0f, 57i, 1.2f, v_gold, cw_thread, cw_block, cw_grid);
      } else {
        var cw_tmp_34: i32;
        if ((v_mode == 4i)) {
          cw_tmp_34 = 39i;
        } else {
          cw_tmp_34 = 40i;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 210.0f, cw_tmp_34, 4.0f, v_ivory, cw_thread, cw_block, cw_grid);
        var cw_tmp_35: f32;
        if ((v_vw < 700.0f)) {
          cw_tmp_35 = 1.0f;
        } else {
          cw_tmp_35 = 1.3f;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 276.0f, 38i, cw_tmp_35, v_dim, cw_thread, cw_block, cw_grid);
        v_c = f_number(v_c, v_x, v_y, (v_cx - 46.0f), 333.0f, (i32(b_S[6i]) / 60i), 2i, 2.5f, v_ivory, cw_thread, cw_block, cw_grid);
        v_c = f_blend(v_c, v_gold, f_glyph((v_x - (v_cx - 11.0f)), (v_y - 333.0f), 58i, 2.5f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        v_c = f_number(v_c, v_x, v_y, (v_cx + 12.0f), 333.0f, (i32(b_S[6i]) % 60i), 2i, 2.5f, v_ivory, cw_thread, cw_block, cw_grid);
        v_c = f_centered(v_c, v_x, v_y, (v_cx - 65.0f), 383.0f, 11i, 1.3f, v_gold, cw_thread, cw_block, cw_grid);
        v_c = f_number(v_c, v_x, v_y, (v_cx - 4.0f), 383.0f, i32(b_S[12i]), 5i, 1.3f, v_ivory, cw_thread, cw_block, cw_grid);
        var cw_tmp_36: f32;
        if ((v_vw < 700.0f)) {
          cw_tmp_36 = 1.0f;
        } else {
          cw_tmp_36 = 1.3f;
        }
        v_c = f_centered(v_c, v_x, v_y, v_cx, 446.0f, 41i, cw_tmp_36, v_dim, cw_thread, cw_block, cw_grid);
        v_c = f_centered(v_c, v_x, v_y, v_cx, 516.0f, 42i, 1.7f, v_gold, cw_thread, cw_block, cw_grid);
      }
    }
  }
  if ((((b_S[47i] > 0.5f) && (v_mode != 0i)) && (v_mode != 3i))) {
    var cw_tmp_37: f32;
    if ((v_vw > 900.0f)) {
      cw_tmp_37 = (v_vw - 206.0f);
    } else {
      cw_tmp_37 = v_cx;
    }
    var v_bx: f32 = cw_tmp_37;
    var v_by: f32 = 276.0f;
    v_c = f_label(v_c, v_x, v_y, (v_bx - 151.0f), (v_by - 121.0f), 43i, 1.8f, v_ivory, cw_thread, cw_block, cw_grid);
    {
      var v_k: i32 = 0i;
      loop {
        if (!(v_k < 6i)) { break; }
        var v_val: f32 = b_Brain[0i];
        if ((v_k == 1i)) {
          v_val = b_Brain[1i];
        }
        if ((v_k == 2i)) {
          v_val = (b_Brain[2i] * 10000.0f);
        }
        if ((v_k == 3i)) {
          v_val = (b_Brain[3i] * 10000.0f);
        }
        if ((v_k == 4i)) {
          v_val = (b_Brain[4i] * 100.0f);
        }
        if ((v_k == 5i)) {
          v_val = b_Brain[12i];
        }
        var v_yy: f32 = ((v_by - 79.0f) + (f32(v_k) * 29.0f));
        v_c = f_label(v_c, v_x, v_y, (v_bx - 151.0f), v_yy, (44i + v_k), 1.1f, v_dim, cw_thread, cw_block, cw_grid);
        if (((v_k == 2i) || (v_k == 3i))) {
          v_c = f_number(v_c, v_x, v_y, (v_bx + 82.0f), v_yy, (i32(v_val) / 10000i), 1i, 1.0f, v_ivory, cw_thread, cw_block, cw_grid);
          v_c = f_blend(v_c, v_ivory, f_glyph(((v_x - v_bx) - 88.0f), (v_y - v_yy), 46i, 1.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
          v_c = f_number(v_c, v_x, v_y, (v_bx + 94.0f), v_yy, (i32(v_val) % 10000i), 4i, 1.0f, v_ivory, cw_thread, cw_block, cw_grid);
        } else {
          v_c = f_number(v_c, v_x, v_y, (v_bx + 82.0f), v_yy, i32(v_val), 6i, 1.0f, v_ivory, cw_thread, cw_block, cw_grid);
        }
        continuing {
          v_k += i32(1);
        }
      }
    }
    v_c = f_centered(v_c, v_x, v_y, v_bx, (v_by + 116.0f), 50i, 0.8f, v_gold, cw_thread, cw_block, cw_grid);
  }
  b_Pixels[((v_iy * cw_params.p_width) + v_ix)] = f_rgba(v_c, cw_thread, cw_block, cw_grid);
}
