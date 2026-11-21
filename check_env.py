"""Verifica que el entorno de BolTox esté listo."""
import sys
import rdkit
import pandas
import numpy
import sklearn
import xgboost
import shap
from rdkit import Chem
from rdkit.Chem import Descriptors

print("Python  :", sys.version.split()[0])
print("RDKit   :", rdkit.__version__)
print("pandas  :", pandas.__version__)
print("numpy   :", numpy.__version__)
print("sklearn :", sklearn.__version__)
print("xgboost :", xgboost.__version__)
print("shap    :", shap.__version__)

# Prueba química: el etanol se escribe CCO en notación SMILES.
mol = Chem.MolFromSmiles("CCO")
print("Átomos  :", mol.GetNumAtoms())
print("Masa    :", round(Descriptors.MolWt(mol), 2))