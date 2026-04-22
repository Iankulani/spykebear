#!/usr/bin/env python3
"""
SPYKE BEAR - Setup Script
"""

from setuptools import setup, find_packages
import os

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as f:
    requirements = [line.strip() for line in f if line.strip() and not line.startswith("#")]

setup(
    name="spykebear",
    version="1.0.0",
    author="Ian Carter Kulani",
    author_email="iancarterkulan@gmail.com",
    description="Cybersecurity Command Center with Multi-Platform Bot Integration",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Iankulani/spykebear",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Information Technology",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Security",
        "Topic :: System :: Networking :: Monitoring",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "spykebear=spykebear:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)