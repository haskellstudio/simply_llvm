{-# LANGUAGE NoImplicitPrelude #-}

module Codegen where

import Protolude hiding (Type)
import LLVM.AST
import qualified LLVM.AST as AST
import LLVM.AST.Global
import LLVM.Context
import LLVM.Module


int :: Type
int = IntegerType 32


defAdd :: Definition
defAdd = GlobalDefinition functionDefaults
  { name = Name "add"
  , parameters =
      ( [ Parameter int (Name "a") []
        , Parameter int (Name "b") [] ]
      , False )
  , returnType = int
  , basicBlocks = [body]
  }
  where
    body = BasicBlock
        (Name "entry")
        [ Name "result" :=
            Add False  -- no signed wrap
                False  -- no unsigned wrap
                (LocalReference int (Name "a"))
                (LocalReference int (Name "b"))
                []]
        (Do $ Ret (Just (LocalReference int (Name "result"))) [])


module_ :: AST.Module
module_ = defaultModule
  { moduleName = "simply-llvm"
  , moduleDefinitions = [defAdd]
  }


toLLVM :: AST.Module -> IO ()
toLLVM llvmAst = withContext $ \ctx -> do
    llvm <- withModuleFromAST ctx llvmAst moduleLLVMAssembly
    putStrLn llvm


-- $ ghci Codegen.hs
--
-- > toLLVM module_
