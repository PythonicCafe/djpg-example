import time

from django.db.models import Q
from django.http import HttpResponseBadRequest
from django.shortcuts import render

from dataset.models import Empresa1, Empresa2, Empresa3, Empresa4, Empresa5


available_models = {
    "Empresa1": Empresa1,
    "Empresa2": Empresa2,
    "Empresa3": Empresa3,
    "Empresa4": Empresa4,
    "Empresa5": Empresa5,
}

def search(request):
    model_name = request.GET.get("model") or "Empresa1"
    uf = request.GET.get("uf") or ""
    query = request.GET.get("query") or ""

    if model_name not in available_models:
        return HttpResponseBadRequest("Invalid model name")

    results = []
    total_time = None
    if uf or query:
        Model = available_models[model_name]
        start = time.time()
        results = Model.objects.filter(codigo_situacao_cadastral=2)
        if uf:
            results = results.filter(uf=uf)
        if query:
            if model_name in ("Empresa1", "Empresa2", "Empresa3"):
                results = results.filter(Q(razao_social__icontains=query) | Q(nome_fantasia__icontains=query))
            elif model_name in ("Empresa4", "Empresa5"):
                results = results.search(query, language="portuguese")
        results = list(results[:100])
        end = time.time()
        total_time = f"{end - start:.3f}"

    return render(
        request,
        "search.html",
        {
            "query": query,
            "uf": uf,
            "total_time": total_time,
            "results": results,
            "uf_list": [
                "AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "EX", "GO", "MA", "MG", "MS", "MT", "PA", "PB", "PE",
                "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO",
            ],
            "models": [f"Empresa{x}" for x in range(1, 5 + 1)],
            "model": model_name,
        },
    )
