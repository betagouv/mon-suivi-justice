# Mise en production

## Environnements

4 environnements existent sur l'application SMS de Mon Suivi Justice :

- L'environnement local de développement
- L'environnement de **staging** qui est dédié aux tests techniques en condition de production et accessible sur [https://agents.mon-suivi-justice.incubateur.net/](https://agents.mon-suivi-justice.incubateur.net/)
- L'application de **démo** qui est dédiée aux démos utilisateur et accessible sur [https://mon-suivi-justice-demo.osc-secnum-fr1.scalingo.io/](https://mon-suivi-justice-demo.osc-secnum-fr1.scalingo.io/)
- L'application de **production** qui est accessible sur [https://agents.mon-suivi-justice.beta.gouv.fr/](https://agents.mon-suivi-justice.beta.gouv.fr/)

## Processus de déploiement

Le processus de mise en production est le suivant :

- L'environnement de **staging** est déployé automatiquement dès que du code est pushé sur Github dans la branche `develop`
- Les environnements de **démo** et de **production** peuvent être déployés de 2 manières :
  - Via le script `deploy-prod`. Le script est à lancer depuis la branche `develop` après avoir pull `develop` et `master`. Il présentera les changements qui vont être pushés puis les déploiera sur les environnements de démo et de prod.
  - Via Scalingo, depuis :
    - L'application de démo : [onglet déploiement manuel](https://dashboard.scalingo.com/apps/osc-secnum-fr1/mon-suivi-justice-demo/deploy/manual)
    - L'application de prod : [onglet déploiement manuel](https://dashboard.scalingo.com/apps/osc-secnum-fr1/mon-suivi-justice-prod/deploy/manual)

    Dans les 2 cas, la branche à déployer est la branche `master`