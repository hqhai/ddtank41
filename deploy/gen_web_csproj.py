#!/usr/bin/env python3
"""Generate SDK-style project files for the legacy ASP.NET projects (Road.Flash, Tank.Request,
Tank.Flash) so they can be compiled with the cross-platform `dotnet build` (no Visual Studio /
WebApplication targets needed). The generated projects compile exactly the <Compile> items of the
original .csproj files.

usage: gen_web_csproj.py SRC_ROOT
"""
import os
import re
import sys
import xml.etree.ElementTree as ET

NS = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}

PROJECTS = {
    # dir: (legacy csproj, assembly name, project references, extra framework references, nuget packages, local dlls)
    "Road.Flash": ("Road.Flash.csproj", "Road.Flash", ["SqlDataProvider"],
                   ["System.Configuration", "System.Web", "System.Xml.Linq"],
                   {"log4net": "2.0.14", "Newtonsoft.Json": "13.0.1"}, []),
    "Tank.Request": ("Tank.Request.csproj", "Tank.Request", ["Bussiness", "Game.Base", "Road.Flash", "SqlDataProvider"],
                     ["System.Configuration", "System.Data", "System.Data.DataSetExtensions", "System.Data.Linq",
                      "System.Drawing", "System.Net.Http", "System.ServiceModel", "System.Runtime.Serialization",
                      "System.Web", "System.Web.ApplicationServices", "System.Web.Extensions", "System.Web.Services",
                      "System.Xml", "System.Xml.Linq"],
                     {"log4net": "2.0.14", "Newtonsoft.Json": "13.0.1", "Microsoft.AspNet.WebApi.Client": "5.2.7",
                      "Microsoft.AspNet.WebApi.Core": "5.2.7", "Microsoft.AspNet.WebApi.WebHost": "5.2.7"},
                     ["lib/Ajax.dll", "lib/zlib.net.dll"]),
    "Tank.Flash": ("Tank.Flash.Single.csproj", "Tank.Flash", ["Bussiness", "Road.Flash", "SqlDataProvider"],
                   ["System.Configuration", "System.Data", "System.Data.DataSetExtensions", "System.Data.Linq",
                    "System.Drawing", "System.Web", "System.Web.ApplicationServices", "System.Web.Extensions",
                    "System.Web.Services", "System.Xml", "System.Xml.Linq"],
                   {"log4net": "2.0.14"}, []),
}


def compile_items(csproj):
    tree = ET.parse(csproj)
    items = []
    for c in tree.getroot().iterfind(".//m:Compile", NS):
        inc = c.get("Include").replace("\\", "/")
        items.append(inc)
    return items


def main(root):
    for d, (legacy, asm, refs, fx, pkgs, dlls) in PROJECTS.items():
        pdir = os.path.join(root, d)
        items = [i for i in compile_items(os.path.join(pdir, legacy)) if os.path.exists(os.path.join(pdir, i))]
        out = ['<Project Sdk="Microsoft.NET.Sdk">',
               '  <PropertyGroup>',
               '    <TargetFramework>net472</TargetFramework>',
               f'    <AssemblyName>{asm}</AssemblyName>',
               '    <OutputType>Library</OutputType>',
               '    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>',
               '    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>',
               '    <LangVersion>latest</LangVersion>',
               '    <NoWarn>$(NoWarn);CS0618;CS0168;CS0219;CS0162;CS0414;CS0649;CS0169;CS0108</NoWarn>',
               '  </PropertyGroup>',
               '  <ItemGroup>']
        out += [f'    <Compile Include="{i}" />' for i in items]
        out += ['  </ItemGroup>', '  <ItemGroup>']
        out += [f'    <Reference Include="{r}" />' for r in fx]
        for dll in dlls:
            name = os.path.splitext(os.path.basename(dll))[0]
            out.append(f'    <Reference Include="{name}"><HintPath>{dll}</HintPath></Reference>')
        out += ['  </ItemGroup>', '  <ItemGroup>']
        out += [f'    <PackageReference Include="{k}" Version="{v}" />' for k, v in pkgs.items()]
        out += ['  </ItemGroup>', '  <ItemGroup>']
        for r in refs:
            target = f"../{r}/{r}.build.csproj" if r in PROJECTS else f"../{r}/{r}.csproj"
            out.append(f'    <ProjectReference Include="{target}" />')
        out += ['  </ItemGroup>', '</Project>', '']
        with open(os.path.join(pdir, f"{d}.build.csproj"), "w") as f:
            f.write("\n".join(out))
        print(f"generated {d}/{d}.build.csproj ({len(items)} source files)")


if __name__ == "__main__":
    main(sys.argv[1])
