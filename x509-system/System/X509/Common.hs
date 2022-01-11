module System.X509.Common
  ( getEnvOverride,
    withEnvOverride
  )
where

import Data.Foldable (asum)
import Data.Maybe (catMaybes)
import Data.Monoid (mconcat)
import Data.X509.CertificateStore
import System.Environment (lookupEnv)

getEnvOverride :: IO (Maybe String)
getEnvOverride =
  asum
    <$> traverse
      lookupEnv
      [ "SSL_CERT_FILE",
        "SSL_CERT_DIR"
      ]

withEnvOverride :: IO CertificateStore -> IO CertificateStore
withEnvOverride defaults = do
  overrideCertPaths <- getEnvOverride
  case overrideCertPaths of
    Nothing -> defaults
    Just certPath -> mconcat . catMaybes <$> (mapM readCertificateStore [certPath])